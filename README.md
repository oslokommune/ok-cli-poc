# ok CLI

Improves the UX when working with AWS and Terraform/Pulumi environments. 

## Installation

* Git clone this repo. Add it to your PATH.
* If you use Fish, copy files in [user-config/fish](user-config/fish) to `~/.config/.fish`.

## Usage

* Download [env-dev.yaml](env-dev.yaml).
* Run

```shell
. ok venv -f env-dev.yaml
```

This sets up environment variables to be used by AWS and the Terraform setup defined in https://github.com/oslokommune/okctl-iac-poc.

# Wildnotes

## Prinsipper / Tanker for et CLI-verktøy

- Hjelpescripts i hverdagen er en nødvendighet, og noe vi ønsker å beholde fra Okctl.
    - Selv lager jeg hjelpescripts hele tiden i min utviklerhverdag for å forbedre DX/UX. Som applikasjonsutvikler ville jeg
      ønsket at noen (mao. Kjøremiljø) kunne lagd disse, og gjerne at jeg kunne bidratt til de selv.
- Å ha ett CLI som Okctl er en god ide. Man kunne i prinsippet hatt et GitHub-repository som alle utviklere putta i PATH-en sin, men det er enklere å oppdatere et CLI (med installasjonscript, ovm, brew/apt) enn at alle
  skal kjøre git pull hele tiden.
  - På ITAS Classic gjorde man dette. Eksempler:

```sh
i itas deploy # Deploye applikasjon
i github add-member # Legge til bruker
i f5 # Gjøre operasjoner i BIGIP
i security edit-secret # Redigere secret
```

NB! Poenget her er å samle script i ett verktøy (`i`), ikke selve kommandoene.

- Okctl skal spille på lag med eksisterende verktøy som finnes der ute (aws cli, terraform, pulumi, alskens verktøy fra 
  internett). Okctl skal ikke være en hindring, eller være et begrensende abstraksjonslag. Okctl skal likevel kunne gjøre
  opplevelsen og sammensyingen av disse verktøyene bedre. Hvis Okctl tryner, skal det fortsatt være mulig å gjøre ting manuelt.
    - Eksempel: Vi skal ikke måtte lage støtte for SSO før brukere kan ta det i bruk, det skal være mulig å bruke eksisterende
      verktøy. Når det er sagt, kan vi godt likevel lage en smoothere UX-løsning for å logge inn.
- Som applikasjonsutvikler ønsker jeg at Kjøremiljø hjelper meg med å bruke verktøy som finnes der ute. Samtidig vil jeg ikke
  at noen skjuler essensielle ting for meg, om det er Kubernetes manifester, Terraform eller Pulumi. Dette er ting man blir
  nødt å forstå uansett når problemer oppstår.
- Vurder: Go kan være overkill og slitsomt for enkle scripts, det hadde vært fint om vi kunne bruke Bash der det ga mening, og Go for alt
  utover det. Hvis Okctl kunne forwardet til enkle Bash scripts er det også lettere for andre utviklere å bidra. (Implementasjon: Okctl kan feks klone et bash-scripts repo. `okctl somecommand` kan forwarde til `scriptsrepo/somecommand`.) Men tygg litt på denne, vi ønsker _ikke_ kompliserte scripts, da er Go og typede språk bedre.
  
Kommandoen laster ned github.com/oslokommune/okctl/pulumi/ecs/cluster, som er -bruk- av en ecs komponent (tilsvarer TF modul),
ikke selve komponenten. I Pulumi gjør man det med package.json, i Terraform bruker referer man til en modul med versjon i GitHub.

## Tanker om implementasjon

Nytt verktøy, feks `ok`.

Installer med

```sh
brew tap oslokommune/ok-cli
brew install oslokommune/ok-cli/ok
```


```shell
. <(ok sso login)
# eller
. <(ok venv -e env-dev.yaml)

ok ecs scaffold cluster
ok ecs scaffold service
ok lambda scaffold

ok completion
ok version
```

### Kommandoer

```shell
# Logge inn til miljø, alternativ 1:
. <(ok sso login) # Se forslag til implementasjon i sso-login.md

# Logge inn til miljø, alternativ 2:
. <(ok venv -e env-dev.yaml) #
. <(ok venv -e env-dev.yaml --terminal fish)

ok ecs scaffold cluster
ok ecs scaffold service
ok lambda scaffold
```

* `okctl venv` kan beholdes, men skrives om til å bruke `source okctl venv`, se forslag i
  * https://trello.com/c/MMGaZQZa/532-okctl-venv-sets-wrong-awsprofile.

### Detaljer

```shell
$ okctl ecs scaffold cluster

Gennerating Pulumi...

Fire up your new component by running:

cd remote_state
pl preview
pl up

cd ecs
pl preview
pl up
```

# Todo

* Put `ok` in apt and brew.
