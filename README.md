# profile_website

![pdk-validate](https://github.com/ncsa/puppet-profile_website/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_website/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure an Apache HTTPd website

# This module is still in development and should not yet be used on a production host

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profile_website](#setup)
    * [What profile_website affects](#what-profile_website-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with profile_website](#beginning-with-profile_website)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This puppet profile configures a host with basic Apache HTTPd web service according to NCSA's recommended practices.

## Setup

Include profile_website in a puppet profile file:
```
include ::profile_website
```

## Usage

The goal is that no paramters are required to be set. The default paramters should work for most NCSA deployments out of the box.

## Reference

See: [REFERENCE.md](REFERENCE.md)

## Limitations

n/a

## Development

This Common Puppet Profile is managed by NCSA for internal usage.
