"""
Helper file to store all error codes in one place so it is easier to keep track and
add new error codes
"""

ERR_REQUEST_INVALID = "error:invalid_request"
ERR_SESSION_EXISTS = "error:session_exists"
ERR_SESSION_NON_EXISTENT = "error:session_non_existent"
ERR_SESSION_PASSWORD_MISMATCH = "error:password_mismatch"
ERR_SESSION_SINGLE_PLAYER = "error:only_one_player_in_session"
ERR_SESSION_FULL = "error:session_full"
ERR_SESSION_PLAYER_NAME_IN_USE = "error:player_name_in_use"
ERR_SESSION_PLAYER_NON_EXISTENT = "error:non_existent_player"
ERR_SESSION_PLAYER_NON_HOST = "error:non_host_player"
ERR_SESSION_PLAYER_KICKED_BY_HOST = "error:kicked_by_host"
ERR_SESSION_PLAYER_EXIT = "error:player_exited_session"
ERR_SESSION_NOT_STARTED = "error:session_not_started"
ERR_SESSION_TIMEOUT = "error:session_timeout"
ERR_PLAYER_TIMEOUT = "error:player_timeout"
