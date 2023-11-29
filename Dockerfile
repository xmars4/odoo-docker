FROM odoo:16

# Use root user to handle logging easier
USER root

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get remove --purge postgresql-client -y \
    && apt-get install --no-install-recommends -y postgresql-client-16 \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

COPY ./requirements.txt /etc/odoo/requirements.txt
RUN pip3 install -r /etc/odoo/requirements.txt

RUN mkdir -p /mnt/et-addons /mnt/custom-addons \
    && chown -R odoo /mnt/et-addons  /mnt/custom-addons \
    && chown odoo /etc/odoo/odoo.conf 

VOLUME ["/mnt/et-addons"]
VOLUME ["/mnt/custom-addons"]
