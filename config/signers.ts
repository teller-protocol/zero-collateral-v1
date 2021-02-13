import { Config, Network, Signers } from '../types/custom/config-types'

export const signersConfigsByNetwork: Config<Signers> = {
  kovan: {
    '_1': '0x8A986034A0972bFBE9bCa9dA02FCc0Dc3289335a',
    '_2': '0x0b09d37BDa56D934a6F7c181cfE27090a3461Da0',
    '_3': '0xA91c5DCd0A6Ed24C3d18bf9C2a8D7Ac04B2B5b05',
    '_4': '0x6d106edc287af63E8B1F6DE7B0f59feC140933da',
    '_5': '0x31F86ECec5C5f54FE8e474F82776CFe89d3cB654',
    '_6': '0xc2AB54A000689e2D37849771B5D504F2b4F47481',
    '_7': '0x23c87d1911E4913eEf8d56553d7efD6664d3FCbe',
    '_8': '0xCC63259aEF94ec5c1C01Ef9A7068Abd99296713a',
    '_9': '0xe7fc2Df46fF34060Cb9c8103354EA302649f526c',
    '_10': '0x957351485f10f5253167B7728B4DA9dB6c1fb548',
    '_11': '0xC8041566cf54021fE8fE8774FBB33221E2a60954',
    '_12': '0x1561F0352657336B43ea4f72492bE08a3E53C728',
    '_13': '0xEA6e2a2f6ff7b8592b5ca7588505cdF0a946EA04',
    '_14': '0xE6eB322a02ff48A20ed977978F00ebdAD2F54A58',
    '_15': '0x579f0C7F3D94A2b7eEEa2E92c0b51576bb53A7E6',
    '_16': '0xa3ae3e8AE6D5Eb606690fc30EE21BBd99aF0fD5F',
    '_17': '0xD5190521AE771Fa0E03461714df91505Ad1AAfB9',
    '_18': '0x24B9bf67fC94D1F62319f16A593b7275945Fa207',
    '_19': '0x970227120d30B114c2C87699a42e0Ac17Bb7080B',
    '_20': '0xdAdAd33B6A411A8C393c1a8B72F26Db24c57Bf87',
    '_21': '0x91687D49d72000Bf61cE3fe6E114AF6536366310',
    '_22': '0x68AbC8c19ca3F0263Ee59CBC8F419D051Fc81B06',
    '_23': '0xFf70D05bD9eF6D25403D736aB4148f7A3da83269',
    '_24': '0x925082d9878D0A1F7630a0EF73E22fF3fb0ae38f',
    '_25': '0xC32eb8eF1cC29EFC309794949aBdC2Ee9ACc1427',
    '_26': '0xC6dfF31CA2fAa258731F583CEc18436e46105A9e',
    '_27': '0xF2b469F237A67c53059bcF0965AC50EB91dB7D69',
    '_28': '0x8f1b0b14af6C014132BdF21eccEB46F0cC0B401E',
    '_29': '0xcA75B6e3D0ed3A9BDA63C51f2fE48C74167cD440'
  },
  rinkeby: {
    '_1': '0x8A986034A0972bFBE9bCa9dA02FCc0Dc3289335a',
    '_2': '0x0b09d37BDa56D934a6F7c181cfE27090a3461Da0',
    '_3': '0xA91c5DCd0A6Ed24C3d18bf9C2a8D7Ac04B2B5b05',
    '_4': '0x6d106edc287af63E8B1F6DE7B0f59feC140933da',
    '_5': '0x31F86ECec5C5f54FE8e474F82776CFe89d3cB654',
    '_6': '0xc2AB54A000689e2D37849771B5D504F2b4F47481',
    '_7': '0x23c87d1911E4913eEf8d56553d7efD6664d3FCbe',
    '_8': '0xCC63259aEF94ec5c1C01Ef9A7068Abd99296713a',
    '_9': '0xe7fc2Df46fF34060Cb9c8103354EA302649f526c',
    '_10': '0x957351485f10f5253167B7728B4DA9dB6c1fb548',
    '_11': '0xC8041566cf54021fE8fE8774FBB33221E2a60954',
    '_12': '0x1561F0352657336B43ea4f72492bE08a3E53C728',
    '_13': '0xEA6e2a2f6ff7b8592b5ca7588505cdF0a946EA04',
    '_14': '0xE6eB322a02ff48A20ed977978F00ebdAD2F54A58',
    '_15': '0x579f0C7F3D94A2b7eEEa2E92c0b51576bb53A7E6',
    '_16': '0xa3ae3e8AE6D5Eb606690fc30EE21BBd99aF0fD5F',
    '_17': '0xD5190521AE771Fa0E03461714df91505Ad1AAfB9',
    '_18': '0x24B9bf67fC94D1F62319f16A593b7275945Fa207',
    '_19': '0x970227120d30B114c2C87699a42e0Ac17Bb7080B',
    '_20': '0xdAdAd33B6A411A8C393c1a8B72F26Db24c57Bf87',
    '_21': '0x91687D49d72000Bf61cE3fe6E114AF6536366310',
    '_22': '0x68AbC8c19ca3F0263Ee59CBC8F419D051Fc81B06',
    '_23': '0xFf70D05bD9eF6D25403D736aB4148f7A3da83269',
    '_24': '0x925082d9878D0A1F7630a0EF73E22fF3fb0ae38f',
    '_25': '0xC32eb8eF1cC29EFC309794949aBdC2Ee9ACc1427',
    '_26': '0xC6dfF31CA2fAa258731F583CEc18436e46105A9e',
    '_27': '0xF2b469F237A67c53059bcF0965AC50EB91dB7D69',
    '_28': '0x8f1b0b14af6C014132BdF21eccEB46F0cC0B401E',
    '_29': '0xcA75B6e3D0ed3A9BDA63C51f2fE48C74167cD440'
  },
  ropsten: {
    '_1': '0x8A986034A0972bFBE9bCa9dA02FCc0Dc3289335a',
    '_2': '0x0b09d37BDa56D934a6F7c181cfE27090a3461Da0',
    '_3': '0xA91c5DCd0A6Ed24C3d18bf9C2a8D7Ac04B2B5b05',
    '_4': '0x6d106edc287af63E8B1F6DE7B0f59feC140933da',
    '_5': '0x31F86ECec5C5f54FE8e474F82776CFe89d3cB654',
    '_6': '0xc2AB54A000689e2D37849771B5D504F2b4F47481',
    '_7': '0x23c87d1911E4913eEf8d56553d7efD6664d3FCbe',
    '_8': '0xCC63259aEF94ec5c1C01Ef9A7068Abd99296713a',
    '_9': '0xe7fc2Df46fF34060Cb9c8103354EA302649f526c',
    '_10': '0x957351485f10f5253167B7728B4DA9dB6c1fb548',
    '_11': '0xC8041566cf54021fE8fE8774FBB33221E2a60954',
    '_12': '0x1561F0352657336B43ea4f72492bE08a3E53C728',
    '_13': '0xEA6e2a2f6ff7b8592b5ca7588505cdF0a946EA04',
    '_14': '0xE6eB322a02ff48A20ed977978F00ebdAD2F54A58',
    '_15': '0x579f0C7F3D94A2b7eEEa2E92c0b51576bb53A7E6',
    '_16': '0xa3ae3e8AE6D5Eb606690fc30EE21BBd99aF0fD5F',
    '_17': '0xD5190521AE771Fa0E03461714df91505Ad1AAfB9',
    '_18': '0x24B9bf67fC94D1F62319f16A593b7275945Fa207',
    '_19': '0x970227120d30B114c2C87699a42e0Ac17Bb7080B',
    '_20': '0xdAdAd33B6A411A8C393c1a8B72F26Db24c57Bf87',
    '_21': '0x91687D49d72000Bf61cE3fe6E114AF6536366310',
    '_22': '0x68AbC8c19ca3F0263Ee59CBC8F419D051Fc81B06',
    '_23': '0xFf70D05bD9eF6D25403D736aB4148f7A3da83269',
    '_24': '0x925082d9878D0A1F7630a0EF73E22fF3fb0ae38f',
    '_25': '0xC32eb8eF1cC29EFC309794949aBdC2Ee9ACc1427',
    '_26': '0xC6dfF31CA2fAa258731F583CEc18436e46105A9e',
    '_27': '0xF2b469F237A67c53059bcF0965AC50EB91dB7D69',
    '_28': '0x8f1b0b14af6C014132BdF21eccEB46F0cC0B401E'
  },
  hardhat: {
    '_1': '0x8A986034A0972bFBE9bCa9dA02FCc0Dc3289335a',
    '_2': '0x0b09d37BDa56D934a6F7c181cfE27090a3461Da0',
    '_3': '0xA91c5DCd0A6Ed24C3d18bf9C2a8D7Ac04B2B5b05',
    '_4': '0x6d106edc287af63E8B1F6DE7B0f59feC140933da',
    '_5': '0x31F86ECec5C5f54FE8e474F82776CFe89d3cB654',
    '_6': '0xc2AB54A000689e2D37849771B5D504F2b4F47481',
    '_7': '0x23c87d1911E4913eEf8d56553d7efD6664d3FCbe',
    '_8': '0xCC63259aEF94ec5c1C01Ef9A7068Abd99296713a',
    '_9': '0xe7fc2Df46fF34060Cb9c8103354EA302649f526c',
    '_10': '0x957351485f10f5253167B7728B4DA9dB6c1fb548',
    '_11': '0xC8041566cf54021fE8fE8774FBB33221E2a60954',
    '_12': '0x1561F0352657336B43ea4f72492bE08a3E53C728',
    '_13': '0xEA6e2a2f6ff7b8592b5ca7588505cdF0a946EA04',
    '_14': '0xE6eB322a02ff48A20ed977978F00ebdAD2F54A58',
    '_15': '0x579f0C7F3D94A2b7eEEa2E92c0b51576bb53A7E6',
    '_16': '0xa3ae3e8AE6D5Eb606690fc30EE21BBd99aF0fD5F',
    '_17': '0xD5190521AE771Fa0E03461714df91505Ad1AAfB9',
    '_18': '0x24B9bf67fC94D1F62319f16A593b7275945Fa207',
    '_19': '0x970227120d30B114c2C87699a42e0Ac17Bb7080B',
    '_20': '0xdAdAd33B6A411A8C393c1a8B72F26Db24c57Bf87',
    '_21': '0x91687D49d72000Bf61cE3fe6E114AF6536366310',
    '_22': '0x68AbC8c19ca3F0263Ee59CBC8F419D051Fc81B06',
    '_23': '0xFf70D05bD9eF6D25403D736aB4148f7A3da83269',
    '_24': '0x925082d9878D0A1F7630a0EF73E22fF3fb0ae38f',
    '_25': '0x7932aD99AbF361866c88Bb2805647F44c799Af04',
    '_26': '0xE8bF0ceF0Bf531Fd56081Ad0B85706cE37A7FD34',
    '_27': '0x34fA03245325fd8cf67C694685932B73aC73666C',
    '_28': '0x981D72d7E8dCaeae14D10db3A94f50958904C117',
    '_29': '0xa75f98d2566673De80Ac4169Deab45c6adad3164',
    '_30': '0x924Af6Cfa15F76E04763D9e24a1c892fD7767983'
  },
  localhost: {
    '_1': '0x8A986034A0972bFBE9bCa9dA02FCc0Dc3289335a',
    '_2': '0x0b09d37BDa56D934a6F7c181cfE27090a3461Da0',
    '_3': '0xA91c5DCd0A6Ed24C3d18bf9C2a8D7Ac04B2B5b05',
    '_4': '0x6d106edc287af63E8B1F6DE7B0f59feC140933da',
    '_5': '0x31F86ECec5C5f54FE8e474F82776CFe89d3cB654',
    '_6': '0xc2AB54A000689e2D37849771B5D504F2b4F47481',
    '_7': '0x23c87d1911E4913eEf8d56553d7efD6664d3FCbe',
    '_8': '0xCC63259aEF94ec5c1C01Ef9A7068Abd99296713a',
    '_9': '0xe7fc2Df46fF34060Cb9c8103354EA302649f526c',
    '_10': '0x957351485f10f5253167B7728B4DA9dB6c1fb548',
    '_11': '0xC8041566cf54021fE8fE8774FBB33221E2a60954',
    '_12': '0x1561F0352657336B43ea4f72492bE08a3E53C728',
    '_13': '0xEA6e2a2f6ff7b8592b5ca7588505cdF0a946EA04',
    '_14': '0xE6eB322a02ff48A20ed977978F00ebdAD2F54A58',
    '_15': '0x579f0C7F3D94A2b7eEEa2E92c0b51576bb53A7E6',
    '_16': '0xa3ae3e8AE6D5Eb606690fc30EE21BBd99aF0fD5F',
    '_17': '0xD5190521AE771Fa0E03461714df91505Ad1AAfB9',
    '_18': '0x24B9bf67fC94D1F62319f16A593b7275945Fa207',
    '_19': '0x970227120d30B114c2C87699a42e0Ac17Bb7080B',
    '_20': '0xdAdAd33B6A411A8C393c1a8B72F26Db24c57Bf87',
    '_21': '0x91687D49d72000Bf61cE3fe6E114AF6536366310',
    '_22': '0x68AbC8c19ca3F0263Ee59CBC8F419D051Fc81B06',
    '_23': '0xFf70D05bD9eF6D25403D736aB4148f7A3da83269',
    '_24': '0x925082d9878D0A1F7630a0EF73E22fF3fb0ae38f',
    '_25': '0x7932aD99AbF361866c88Bb2805647F44c799Af04',
    '_26': '0xE8bF0ceF0Bf531Fd56081Ad0B85706cE37A7FD34',
    '_27': '0x34fA03245325fd8cf67C694685932B73aC73666C',
    '_28': '0x981D72d7E8dCaeae14D10db3A94f50958904C117',
    '_29': '0xa75f98d2566673De80Ac4169Deab45c6adad3164',
    '_30': '0x924Af6Cfa15F76E04763D9e24a1c892fD7767983'
  },
  mainnet: {
    '_1': '0x0cA59Bd2255Ae40D4E1e3b939C3a97b5C9dE839b',
    '_2': '0x53E88c675f9cb51c8CB33edf090582ac2FFDa01F',
    '_3': '0xd380829600546D4B3b6aC5F0d9D5ED97cF799b92',
    '_4': '0x8bCd79c2AE760E70573fCFA4e4460a7B3C8A3134',
    '_5': '0x312a5217c12aD9b206A0380B4B134ef2b02d09A5'
  }
}

export const getSigners = (network: Network) => signersConfigsByNetwork[network]
