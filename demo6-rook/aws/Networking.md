
# Enchanced Networking in AWS

```
# sudo modinfo ena 
filename:       /lib/modules/4.4.0-1052-aws/kernel/drivers/net/ethernet/amazon/ena/ena.ko
version:        1.3.0K
license:        GPL
description:    Elastic Network Adapter (ENA)
author:         Amazon.com, Inc. or its affiliates
srcversion:     1241EF5573826B9EA2A7ACF
alias:          pci:v00001D0Fd0000EC21sv*sd*bc*sc*i*
alias:          pci:v00001D0Fd0000EC20sv*sd*bc*sc*i*
alias:          pci:v00001D0Fd00001EC2sv*sd*bc*sc*i*
alias:          pci:v00001D0Fd00000EC2sv*sd*bc*sc*i*
depends:        
intree:         Y
vermagic:       4.4.0-1052-aws SMP mod_unload modversions retpoline 
parm:           debug:Debug level (0=none,...,16=all) (int)



# aws ec2 describe-instances --instance-ids <instamce_id> --query 'Reservations[].Instances[].EnaSupport'
[
    true
]


# aws ec2 describe-images --image-id ami-43a15f3e --query 'Images[].EnaSupport'
[
    true
]


# sudo ethtool -i ens5
driver: ena 
version: 1.3.0K
firmware-version: 
expansion-rom-version: 
bus-info: 0000:00:05.0
supports-statistics: yes
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no

```