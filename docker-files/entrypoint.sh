#!/bin/bash

set -e

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"


UPDATE_MODULES_PARAM=update_addons
UPDATE_MODULES=
function get_update_modules() {
    if grep -q -E "^\s*\b${UPDATE_MODULES_PARAM}\b\s*=" "$ODOO_RC" ; then
        UPDATE_MODULES=$(grep -E "^\s*\b${UPDATE_MODULES_PARAM}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
}
get_update_modules

INSTALL_MODULES_PARAM=install_addons
INSTALL_MODULES=
function get_install_modules() {
    if grep -q -E "^\s*\b${INSTALL_MODULES_PARAM}\b\s*=" "$ODOO_RC" ; then
        INSTALL_MODULES=$(grep -E "^\s*\b${INSTALL_MODULES_PARAM}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
}
get_install_modules


DB_NAME_PARAM=db_name
DB_NAME=
function get_db_name() {
    if grep -q -E "^\s*\b${DB_NAME_PARAM}\b\s*=" "$ODOO_RC" ; then
        DB_NAME=$(grep -E "^\s*\b${DB_NAME_PARAM}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
}
get_db_name


# "$@" meaning pass all arguments from previous command to current command
function run_odoo() {
    wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
    if [[ -n $DB_NAME ]] ; then
        if [[ -n $INSTALL_MODULES ]] ; then
            exec odoo "$@" "${DB_ARGS[@]}" -d "$DB_NAME" -i "$INSTALL_MODULES"
        elif [[ -n $UPDATE_MODULES ]] ; then
            exec odoo "$@" "${DB_ARGS[@]}" -d "$DB_NAME" -u "$UPDATE_MODULES"
        else
            exec odoo "$@" "${DB_ARGS[@]}" -d "$DB_NAME"
        fi
    else
        exec odoo "$@"
    fi
}


case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            run_odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        run_odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
