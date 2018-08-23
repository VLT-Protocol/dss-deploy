pragma solidity ^0.4.24;

import {Vat} from "dss/tune.sol";
import {Pit} from "dss/frob.sol";
import {Dai20} from "dss/transferFrom.sol";
import {Drip} from "dss/drip.sol";
import {Vow} from "dss/heal.sol";
import {Cat} from "dss/bite.sol";
import {Flapper} from "dss/flap.sol";
import {Flopper} from "dss/flop.sol";
import {Flipper} from "dss/flip.sol";

import {Price} from "./poke.sol";

contract VatFab {
    function newVat() public returns (Vat vat) {
        vat = new Vat();
        // vat.setOwner(msg.sender);
    }
}

contract PitFab {
    function newPit(Vat vat) public returns (Pit pit) {
        pit = new Pit(vat);
        // pit.setOwner(msg.sender);
    }
}

contract PieFab {
    function newPie(Vat vat) public returns (Dai20 pie) {
        pie = new Dai20(vat);
        // pie.setOwner(msg.sender);
    }
}

contract DripFab {
    function newDrip(Vat vat) public returns (Drip drip) {
        drip = new Drip(vat);
        // drip.setOwner(msg.sender);
    }
}

contract VowFab {
    function newVow() public returns (Vow vow) {
        vow = new Vow();
        // vow.setOwner(msg.sender);
    }
}

contract CatFab {
    function newCat(Vat vat, Pit pit, Vow vow) public returns (Cat cat) {
        cat = new Cat(vat, pit, vow);
        // cat.setOwner(msg.sender);
    }
}

contract FlapFab {
    function newFlap(Dai20 pie, address gov) public returns (Flapper flap) {
        flap = new Flapper(pie, gov);
        // flap.setOwner(msg.sender);
    }
}

contract FlopFab {
    function newFlop(Dai20 pie, address gov) public returns (Flopper flop) {
        flop = new Flopper(pie, gov);
        // flop.setOwner(msg.sender);
    }
}

contract FlipFab {
    function newFlip(Vat vat, bytes32 ilk) public returns (Flipper flop) {
        flop = new Flipper(vat, ilk);
        // flip.setOwner(msg.sender);
    }
}

contract PriceFab {
    function newPrice(Pit pit, bytes32 ilk) public returns (Price price) {
        price = new Price(pit, ilk);
        // price.setOwner(msg.sender);
    }
}

contract DssDeploy /*is DSAuth*/ {
    VatFab public vatFab;
    PitFab public pitFab;
    PieFab public pieFab;
    DripFab public dripFab;
    VowFab public vowFab;
    CatFab public catFab;
    FlapFab public flapFab;
    FlopFab public flopFab;
    FlipFab public flipFab;
    PriceFab public priceFab;

    Vat public vat;
    Pit public pit;
    Dai20 public pie;
    Drip public drip;
    Vow public vow;
    Cat public cat;
    Flapper public flap;
    Flopper public flop;
    mapping(bytes32 => Ilk) public ilks;

    uint8 public step = 0;

    uint256 constant ONE = 10 ** 27;

    struct Ilk {
        Flipper flip;
        address adapter;
        Price price;
    }

    constructor(VatFab vatFab_, PitFab pitFab_, PieFab pieFab_, DripFab dripFab_, VowFab vowFab_, CatFab catFab_, FlapFab flapFab_, FlopFab flopFab_, FlipFab flipFab_, PriceFab priceFab_) public {
        vatFab = vatFab_;
        pitFab = pitFab_;
        pieFab = pieFab_;
        dripFab = dripFab_;
        vowFab = vowFab_;
        catFab = catFab_;
        flapFab = flapFab_;
        flopFab = flopFab_;
        flipFab = flipFab_;
        priceFab = priceFab_;
    }

    function deployContracts(address gov) public /*auth */{
        require(step == 0);
        vat = vatFab.newVat();
        pit = pitFab.newPit(vat);
        pie = pieFab.newPie(vat);
        drip = dripFab.newDrip(vat);
        vow = vowFab.newVow();
        cat = catFab.newCat(vat, pit, vow);
        flap = flapFab.newFlap(pie, gov);
        flop = flopFab.newFlop(pie, gov);

        vow.file("vat", vat);
        vow.file("flap", flap);
        vow.file("flop", flop);
        step += 1;
    }

    function deployIlk(bytes32 ilk, address adapter, address pip) public /*auth */{
        require(step > 0);
        ilks[ilk].flip = flipFab.newFlip(vat, ilk);
        ilks[ilk].adapter = adapter;
        ilks[ilk].price = priceFab.newPrice(pit, ilk);
        ilks[ilk].price.setPip(pip);
        ilks[ilk].price.setMat(ONE);
        ilks[ilk].price.poke();
        cat.fuss(ilk, ilks[ilk].flip);
        cat.file(ilk, "chop", ONE);
        vat.init(ilk);
        // drip.file(ilk, bytes32(address(vow)), ONE);
    }

    function configParams() public /*auth */{
        require(step == 1);
        step += 1;
    }

    function verifyParams() public /*auth */{
        require(step == 2);
        step += 1;
    }

    function configAuth(/*DSAuthority authority*/) public /*auth */{
        require(step == 3);
        step += 1;
    }
}
