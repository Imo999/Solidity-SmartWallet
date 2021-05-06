// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Création contrat SmartWallet
contract SmartWallet {
    //mapping des adresses
    mapping(address => uint256) private _balances;
    mapping(address => bool) _owners;
    mapping(address => bool) _members;
    address private _owner;
    uint8 private _percentage;
    uint256 private _gain;

    constructor(
        uint256,
        address owner_,
        uint8 percentage_
    ) {
        //Création de groupes
        _owners[msg.sender] = true;
        _members[msg.sender] = true;
        //Création Owner pour Royaties(gain)
        _owner = owner_;
        //Création Poucentage pour Royaties(gain)
        _percentage = percentage_;
    }

    // ############################### ADD & REMOVE Members ################################

    // Add Members
    function addMember(address account) public {
        require(
            // require est une sécurité qui dit : seul le owner peut faire cette manip
            _owners[msg.sender] == true,
            "addMember: Only an Owner and Admin can add member"
        );
        // Le membre à accès a ce goupe
        _members[account] = true;
    }

    //Remove Members
    function RemUser(address account) public {
        // require est une sécurité qui dit : seul le owner peut faire cette manip
        require(
            _owners[msg.sender] == true,
            "RemMember: Only an Owner and Admin can remove member"
        );
        // Le membre n'a plus accès a ce groupe
        _members[account] = false;
    }

    // ############################### Déposite ################################

    //Création de la fonction dépot qui permet de déposer des Token sur le SmartContrat
    //(AVEC - payable - utilisation de Gas)
    function deposit() public payable {
        // require est une sécurité qui dit : seul le owner/membre peut faire cette manip
        require(
            _owners[msg.sender] == true || _members[msg.sender] == true,
            "Deposite: Only an Owner and Member can Deposite funds"
        );
        //l'address ajoute a la Balance(SC) une value
        _balances[msg.sender] += msg.value;
    }

    // ############################### Exerice 1 ################################

    //Création de la fonction WithdrawAmount qui permet à l'address de retirer le nombre de token voulu sur le SmartContrat
    //(AVEC - payable - utilisation de Gas)
    function withdrawAmount() public payable {
        // Require est une sécurité qui dit que en inférieur de la balance 0 il manque des fonds
        require(
            _balances[msg.sender] > 0,
            "withdrawAmount: can not withdraw 0 ether"
        );
        // Montant est égale à la balance de l'address = ça évite une attaque reentrancy attack
        uint256 amount = _balances[msg.sender];
        // Retire le nombre de token voulu balance après l'opération soustraction du montant
        _balances[msg.sender] -= msg.value;
        require(
            _owners[msg.sender] == true || _members[msg.sender] == true,
            "withdrawAmount: Only an Owner and Member can withdrawAmount funds"
        );
        //(AVEC - payable - utilisation de Gas)
        // transfer le montant vers l'address
        payable(msg.sender).transfer(amount);
    }

    // ############################### Exerice 2 ################################

    //Création de la fonction transfer qui permet à l'address de transfer des token d'une adresse à une autre
    //(AVEC - payable - utilisation de Gas)
    function transfer(address account, uint256 amount) public {
        // Require est une sécurité qui dit que en inférieur de la balance 0 il manque des fonds
        require(
            _balances[msg.sender] >= amount,
            "transfer: you don't have enough funds in this account to transfer"
        );
        require(
            _owners[msg.sender] == true || _members[msg.sender] == true,
            "transfer: Only an Owner and Member can transfer funds"
        );
        //Envoie de l'adresse Principal
        _balances[msg.sender] -= amount;
        //Reçois sur ll'adresse du destinataire
        _balances[account] += amount;
    }

    // ############################### Exercice 3 ################################

    //Création de la fonction withdrawRoyal qui permet de retirer ces fond sur une adresse et donner des fees à l'Owner
    //(AVEC - payable - utilisation de Gas)
    function withdrawRoyal(uint256 amount) public {
        // Require est une sécurité qui dit que en inférieur de la balance 0 il manque des fonds
        require(
            _balances[msg.sender] > 0,
            "withdrawAmount: can not withdraw 0 ether"
        );
        uint256 Royalties = (amount * _percentage) / 100;
        _balances[msg.sender] -= Royalties;
        amount -= Royalties;
        _balances[msg.sender] -= amount;
        _balances[_owner] += Royalties;
        _gain += Royalties;
        require(
            _owners[msg.sender] == true || _members[msg.sender] == true,
            "transfer: Only an Owner and Member can withdrawRoyal funds"
        );
        payable(msg.sender).transfer(amount);
    }

    // ############################### Exercice 4 ################################

    //Création de la fonction withdrawRoyal qui permet de retirer ces fond sur une adresse et donner des fees à l'Owner
    //(AVEC - payable - utilisation de Gas)
    function setPercentage(uint8 percentage_) public {
        require(
            // require est une sécurité qui dit : seul le owner peut faire cette manip
            _owners[msg.sender] == true,
            "addMember: Only an Owner can set percentage"
        );
        _percentage = percentage_;
    }

    // ############################### AFFICHAGE ################################

    // Affichage public pour pouvoir voir si l'addresse a pour statut Owner
    function isOwner(address account) public view returns (bool) {
        return _owners[account];
    }

    // Affichage public pour pouvoir voir si l'addresse a pour statut Member
    function isMember(address account) public view returns (bool) {
        return _members[account];
    }

    //Affichage de la Balance du smart contrat
    // C'est une fonction qui affiche le Total() en public View permet à l'utilisateur de voir le résultat
    function total() public view returns (uint256) {
        //Retourne la balance du SmartContrat
        return address(this).balance;
    }

    //Affichage de la Balance de l'adresse demandé
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    //Affichage du Pourc entage de Royalties(gain)
    function percent() public view returns (uint8) {
        return _percentage;
    }

    //Affichage des Royalties(gain)
    function gain() public view returns (uint256) {
        return _gain;
    }
}
