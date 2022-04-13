# ok CLI

Improves the UX when working with AWS and Terraform/Pulumi environments. 

## Installation

* Git clone this repo. Add it to your PATH.

TODO: Put in apt and brew.

* If you use Bash or Zsh, add to ~/.bash_aliases or ~/.zshrc:

```bash
# Helper function to log in to OK environment
function okl() {
    if [[ -z $1 ]]; then
        ok venv -e
    else
        . <(ok venv -e $1)
    fi
}
```

* If you use Fish, add to `~/.config/fish/config.fish`

```shell
function okl --description "Log in to OK environment"
    if test -z $argv[1]
        ok venv -e
    else
        set OUT (ok venv -e $argv)
        echo $OUT | source
    end
end
```

## Usage

```shell

cat <<EOF>env-dev.yaml
apiVersion: ok.env/v1
kind: Environment

metadata:
  project: 'ok-cli-poc'

aws:
  profile: 'ok-cli-poc-dev'
  accountID: '123456789012'
  region: 'eu-west-1'
EOF

okl env-dev.yaml # This will log in to the environment
```

Specifically, it sets up environment variables to be used by AWS and Terraform.

# okctl iterasjon 2 - Løsningsforslag

* Alternativ 1: Lage nytt CLI (`ok`?) som
  * funker som et samlested for hjelpescripts
  * feks produserer Terraform / Pulumi hvor brukeren selv kjører `tf apply` / `pl up`.
  * På sikt fase ut `okctl`.
* Alternativ 2: Implementere alternativ 1 inn i Okctl.
  * På sikt fase ut apply / delete cluster (for EKS).

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


## Implementasjon alternativ 1

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

## Implementasjon alternativ 2

* Dagens EKS-spesifikke kommandoer flyttes til `okctl eks`, så f.eks `okctl eks apply cluster`
* Ikke nødvendig, men foreslår en mer feature basert oppdeling av kommandoer, slik som `aws` CLI-et gjør det (`aws s3 ls`). Eks:
  `okctl ecs scaffold cluster` framfor `okctl scaffold ecs cluster`. `okctl upgrade` gir feks ikke mening for lambda (ok, kanskje,
  men poenget er at ikke alle actions passer til alle ressurser), så derfor burde det være
  `okctl eks upgrade`.
  
Eksempelkommandoer:

```sh
okctl ecs scaffold cluster

# Eksisterende EKS-spesifikke kommandoer flyttes til okctl eks:
okctl eks apply cluster ...
okctl eks delete cluster ...

okctl eks apply application ...
okctl eks upgrade
okctl eks forward

# Eksisterende generelle kommandoer beholdes
okctl completion
okctl version
```
