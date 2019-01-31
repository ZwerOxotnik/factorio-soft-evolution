# Soft evolution

Read this in another language | [English](/README.md) | [Русский](/docs/ru/README.md)
|---|---|---|

## Quick Links

[Changelog](CHANGELOG.md) | [Contributing](CONTRIBUTING.md)
|---|---|

## Contents

* [Overview](#overview)
* [Issues](#issue)
* [Features](#feature)
* [Installing](#installing)
* [Dependencies](#dependencies)
    * [Embedded](#embedded)
* [License](#license)

## Overview

Evolution depend on players, research with different accounting, teams, destroyed buildings, launched rockets. There are settings. Compatible with any PvP scenario. UPS friendly.

## About balanced evolution from research (this not all information)

* After any team has researched any technology, a balance check will be performed that checks all teams.
* If the team has not researched the technology "logistics 2", then the team is not taken into account.
* Checks activity of teams, if the players have not played enough in comparison with the other team that played the most, then that team is not taken into account. (not necessarily)
* After those checks, the evolution factor is calculated.
* The mod counts from each teams the technologies researched + number of rockets launched. After (all technologies researched + number of rockets launched divide by all technology) = new evolution factor (not to be confused with evolution factor, becuase evolution factor will never be more than 100%)
* If "Can balancing be omitted?" set true then
evolution factor = new evolution factor
* If "Can balancing be omitted?" set false then
If evolution factor < new evolution factor then evolution factor = new evolution factor. (It is more difficult to progressing a team that has just begun to play)

## <a name="issue"></a> Found an Issue?

Please report any issues or a mistake in the documentation, you can help us by [submitting an issue][issues] to our GitLab Repository or on [mods.factorio.com][mod portal] or on [forums.factorio.com][homepage].

## <a name="feature"></a> Want a Feature?

You can *request* a new feature by [submitting an issue][issues] to our GitLab Repository or on [mods.factorio.com][mod portal] or on [forums.factorio.com][homepage].

## Installing

If you have downloaded a zip archive:

* simply place it in your mods directory.

For more information, see [Installing Mods on the Factorio wiki](https://wiki.factorio.com/index.php?title=Installing_Mods).

If you have downloaded the source archive (GitLab):

* copy the mod directory into your factorio mods directory
* rename the mod directory to soft-evolution_*versionnumber*, where *versionnumber* is the version of the mod that you've downloaded (e.g., 2.0.0)

## Dependencies

### Embedded

* Event listener: [mods.factorio.com](https://mods.factorio.com/mod/event-listener), [GitLab](https://gitlab.com/ZwerOxotnik/event-listener), [homepage](https://forums.factorio.com/viewtopic.php?f=190&t=64621)

## License

```
MIT License

Copyright (c) 2019 ZwerOxotnik <zweroxotnik@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

[issues]: https://gitlab.com/ZwerOxotnik/soft-evolution/issues
[mod portal]: https://mods.factorio.com/mod/soft-evolution/discussion
[homepage]: https://forums.factorio.com/viewtopic.php?f=190
[Factorio]: https://factorio.com/
