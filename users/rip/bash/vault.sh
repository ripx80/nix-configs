#!/usr/bin/env bash

function vt() {

	vaulty_authy() {
        VAULT_ADDR=$(echo "$2" | jq -r '.vault.address')
        AWS_REGION=$(echo "$2" | jq -r '.aws.region')
        AWS_DEFAULT_REGION=$(echo "$2" | jq -r '.aws.region')

        export VAULT_ADDR
        export AWS_REGION
        export AWS_DEFAULT_REGION

        unset VAULT_TOKEN
        case $(echo "$2" | jq -r '.auth') in
        oidc)
            vault login -method=oidc username="$(echo "$2" | jq -r '.user')"
        ;;
        ldap)
            vault login -method=ldap "$(echo "$2" | jq -r '.user')"
        ;;
        *)
            printf "unknown auth method"
            return
        ;;
        esac

        if [ $? == 0 ]; then
            VAULT_TOKEN=$(cat ~/.vault-token)
            export VAULT_TOKEN
			data=$(vault read -format=json "$1")
			AWS_ACCESS_KEY_ID=$(echo "$data" | jq -r '.data.access_key')
			AWS_SECRET_ACCESS_KEY=$(echo "$data" | jq -r '.data.secret_key')
            export AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY
		fi
	}

    if [ ! "$(which jq)" ]; then
        printf "You must have jq installed to use this script.\n"
        return
    fi

	awsaccounts=(lab1 lab2 prd lab4 prd_read appsjw brdcst brdcst_dev prd_leg travel_dev travel_prd)
	bethel_values=$(<~/bethel_values.json)

	PS3='Select an account: '
	select opt in "${awsaccounts[@]}"; do
		case "$opt" in
		lab1)
			vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.lab1')" "$bethel_values"
			break
			;;
		lab2)
			vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.lab2')" "$bethel_values"
			break
			;;
		prd)
			vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.prd')" "$bethel_values"
			break
			;;
		lab4)
			vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.lab4')" "$bethel_values"
			break
			;;
		prd_read)
			vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.prd_read')" "$bethel_values"
			break
			;;
		appsjw)
			vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.appsjw')" "$bethel_values"
			break
			;;
		brdcst)
			vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.brdcst')" "$bethel_values"
			break
			;;
		brdcst_dev)
			vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.brdcst_dev')" "$bethel_values"
			break
			;;
		prd_leg)
		  vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.prd_leg')" "$bethel_values"
			break
			;;
		travel_dev)
		  vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.travel_dev')" "$bethel_values"
			break
			;;
		travel_prd)
		  vaulty_authy "$(echo "$bethel_values" | jq -r '.vault.environment_creds.travel_prd')" "$bethel_values"
			break
			;;
		*)
			printf "Invalid selection. Please try again.\n"
			;;
		esac
	done

}

function art(){
	artjson=$(vault read -format json artifactory/creds/bethel-adfs-awsorchestrationadmins2)
    unset ARTIFACTORY_URL ARTIFACTORY_USERNAME ARTIFACTORY_ACCESS_TOKEN ARTIFACTORY_API_KEY
	ARTIFACTORY_USERNAME=$(jq -r '.data.username' <<< "$artjson")
	ARTIFACTORY_ACCESS_TOKEN=$(jq -r '.data.access_token' <<< "$artjson")
	ARTIFACTORY_API_KEY=$(jq -r '.data.api_key' <<< "$artjson")
    ARTIFACTORY_PASSWORD=$(jq -r '.data.password' <<< "$artjson")
    export ARTIFACTORY_URL="docker.packages.bethel.jw.org"
    export ARTIFACTORY_USERNAME
    export ARTIFACTORY_ACCESS_TOKEN
    export ARTIFACTORY_API_KEY
    export ARTIFACTORY_PASSWORD
    echo "username: $ARTIFACTORY_USERNAME"
    echo "api_key: $ARTIFACTORY_API_KEY"
    echo "token: $ARTIFACTORY_ACCESS_TOKEN"
    echo "password: $ARTIFACTORY_PASSWORD"
    echo "$ARTIFACTORY_PASSWORD" | docker login --username "$ARTIFACTORY_USERNAME" --password-stdin $ARTIFACTORY_URL
}
