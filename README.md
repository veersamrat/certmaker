CertMaker
===========

A tool to create an OpenSSL certificate authority, and generate certificates, for use on internal networks.

The tool is written with two uses cases in mind:

* As an *internal* CA tool that will act as CA and manage cert/key pairs centrally, distributing them to target servers
    * the `quick` mode is an implementation of this workflow
* As a *CSR client* tool for generating CSRs to be sent to CAs
* As a plain internal CA that can sign individual CSRs

If you are deploying a public-facing web site, please consider using [Let's Encrypt](https://letsencrypt.org)



Install certmaker
-----------------

    sudo ./install.sh

Configuration is palced in `/etc/certmaker/certmaker.config`

If you do not install as root, it is placed in `~/.config/certmaker/certmaker.config`

Ensure your `EDITOR` environment variable is set to your preferred text editor; if it is not set, CertMaker will try to use Emacs, nano, vim or vi.



New CA
---------

Sets up a new CA config, and opens an editor; specifically ensure you update the organisation country and details. You can also edit the `default_days` property to specify the number of days a newly signed cert is valid for. You will be prompted for a password for the key.

    certmaker new ca

Set up a generic hosts config which will be used as a template for managed hosts

    certmaker quick --edit

It is possible to save a password file in plaintext in `$CERTMAKERCONFIG/ca/pass.txt` to allow running in batch mode; treat this with caution.


Centrally managed hosts
-----------------------

If you want the CA to manage both keys and certificates for host machines, use these steps. In this scenario, the CA is responsible for creating both the keys and the certificates that will be placed on host machines.

Create a new host profile - you will be prompted to edit it, and will then be given paths to a key and cert file as a result.

    certmaker quick myhost

Re-run the command any time you want to renew the certificate. You will need to copy the new certificate to the desired host machine to replace the old certificate.



Generic CSR and CA activities
-----------------------------


###    Target host

If you simply want to create a CSR for your machine, to send to a remote CA for signing:

Create a configuration for the CSR, and edit it

    certmaker template host myhost.cnf
    nano myhost.cnf

If you don't already have a key, create one form the config

    certmaker renew key ./myhost.cnf

Finally, create the CSR

    certmaker renew csr ./key-file.key ./myhost.cnf


This will create a CSR file `myhost.csr` to send to the CA



###    Certificate Authority

On receipt of a CSR, simply use the `sign csr` command:

    certmaker sign csr CSRFILE [CERTFILE]

This will generate a certificate file as specified, or with the same base name as the CSR, to send back to the requestor.




View a certificate
------------------

You can inspect the contents of a certificate PEM file (typically a block of base-64 data bounded with `BEGIN` and `END` statements) using

    certmaker view CERTFILE

Certificates generated by CertMaker are always PEM files.


