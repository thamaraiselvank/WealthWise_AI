"""Request authentication.

The app signs in with Firebase Anonymous Auth (no personal details) and
attaches:
  Authorization: Bearer <Firebase ID token>   -> identifies the install for quotas
  X-Firebase-AppCheck: <App Check token>      -> proves the request comes from
                                                 our genuine app (Play Integrity)
In dev both checks can be switched off; prod refuses to start without them.
"""

from dataclasses import dataclass

from fastapi import Depends, Header, HTTPException, status

from .settings import Settings, get_settings


@dataclass(frozen=True)
class Caller:
    user_id: str


_firebase_app = None


def _firebase(settings: Settings):
    global _firebase_app
    if _firebase_app is None:
        import firebase_admin

        opts = {"projectId": settings.firebase_project or settings.gcp_project}
        _firebase_app = firebase_admin.initialize_app(options=opts)
    return _firebase_app


def _unauthorized(detail: str) -> HTTPException:
    return HTTPException(status.HTTP_401_UNAUTHORIZED, detail=detail)


def verify_caller(
    authorization: str | None = Header(default=None),
    x_firebase_appcheck: str | None = Header(default=None),
    settings: Settings = Depends(get_settings),
) -> Caller:
    if settings.require_app_check:
        if not x_firebase_appcheck:
            raise _unauthorized("missing app check token")
        from firebase_admin import app_check

        try:
            app_check.verify_token(x_firebase_appcheck, app=_firebase(settings))
        except Exception:  # noqa: BLE001 - any failure means "not our app"
            raise _unauthorized("invalid app check token") from None

    if settings.require_auth:
        if not authorization or not authorization.startswith("Bearer "):
            raise _unauthorized("missing id token")
        from firebase_admin import auth

        try:
            decoded = auth.verify_id_token(authorization.removeprefix("Bearer "),
                                           app=_firebase(settings))
        except Exception:  # noqa: BLE001
            raise _unauthorized("invalid id token") from None
        return Caller(user_id=decoded["uid"])

    return Caller(user_id="dev-user")
