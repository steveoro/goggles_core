# goggles_core

[![Maintainability](https://api.codeclimate.com/v1/badges/2b8a0414f3e17e51959d/maintainability)](https://codeclimate.com/github/steveoro/goggles_core/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2b8a0414f3e17e51959d/test_coverage)](https://codeclimate.com/github/steveoro/goggles_core/test_coverage)
[![CodeFactor](https://www.codefactor.io/repository/github/steveoro/goggles_core/badge)](https://www.codefactor.io/repository/github/steveoro/goggles_core)
[![Build Status](https://semaphoreci.com/api/v1/steveoro/goggles_core/branches/master/badge.svg)](https://semaphoreci.com/steveoro/goggles_core)

Core engine and modules for Goggles 5.0+

This _full_ engine should contain only:

- models
- strategies
- other pattern objects (services, proxies, whatever...)
- mailers
- current DB structure
- **NO** decorators or other presentation-centric classs
- **NO** DB data or dumps
- full specs for all the above
- versioning info for the DB & core modules & overall framework release
- only the basic Rake tasks for DB rebuild/backup using (externally supplied) data dumps


Official framework Wiki, [here](https://github.com/steveoro/goggles_admin/wiki)
