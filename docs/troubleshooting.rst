Troubleshooting
===============


.. _enabling-debug-logging:

Enabling Debug Logging
----------------------

By default Pulp logs at INFO level, but enabling DEBUG logging can be a helpful thing to get more
insight when things don't go as expected. This can be enabled with dynaconf using the examples
below.

Designating a Python-based settings file, and putting the DEBUG logging configuration there::

    export PULP_SETTINGS=/etc/pulp/settings.py  # Note the installer already does this for you
    echo "LOGGING = {'dynaconf_merge': True, 'loggers': {'': {'handlers': ['console'], 'level': 'DEBUG'}}}" >> /etc/pulp/settings.py

Due to `a bug in Dynaconf <https://github.com/rochacbruno/dynaconf/issues/747>`_, the following
example won't work, but is included for illustrative purposes::

    PULP_LOGGING={'dynaconf_merge': True, 'loggers': {'': {'handlers': ['console'], 'level': 'DEBUG'}}}

.. tip::

    As a workaround, you could specify the entire config with the `PULP_LOGGING` environment variable
    and avoid using the "merge" feature from dynaconf. In that case you would specify
    ``'level': 'DEBUG'`` in addition to your current config shown with ``dynaconf list``.

Then when starting Pulp you should see a lot more information logged.

To ensure you've enabled the settings correctly, view them with the ``dynaconf list`` command (for
more information, see :ref:`viewing-settings`). If configured correctly you should see::

    $ dynaconf list
    <snip>
    LOGGING<dict> {'disable_existing_loggers': False,
    'loggers': {'': {'filters': ['correlation_id'],
                     'handlers': ['console'],
                     'level': 'DEBUG'},  # <--- the DEBUG level
    <snip>
