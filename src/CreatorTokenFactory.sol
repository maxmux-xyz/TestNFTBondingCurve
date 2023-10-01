// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {CreatorToken} from "src/CreatorToken.sol";
import {CTBondingCurve} from "src/CTBondingCurve.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IShowtimeVerifier, Attestation} from "src/lib/IShowtimeVerifier.sol";
import {CreatorTokenDeploymentConfig} from "src/lib/ICreatorTokenFactory.sol";

contract CreatorTokenFactory {
  // struct CreatorTokenDeploymentConfig {
  //   string name;
  //   string symbol;
  //   string tokenURI;
  //   address creator;
  //   uint256 creatorFee;
  //   address admin;
  //   uint256 adminFee;
  //   address referrer;
  //   IERC20 payToken;
  //   uint128 basePrice;
  //   uint128 linearPriceSlope;
  //   uint128 inflectionPrice;
  //   uint32 inflectionPoint;
  //   // bytes32 attestationDigest;
  // }

  event CreatorTokenDeployed(
    CreatorToken indexed creatorToken,
    CTBondingCurve indexed bondingCurve,
    CreatorTokenDeploymentConfig config
  );

  error CreatorTokenFactory__DeploymentNotVerified();

  // TODO: update to be for config + attestation
  bytes public constant DEPLOY_TYPE =
    "CreatorTokenDeploymentConfig(string name,string symbol,string tokenURI,address creator,uint256 creatorFee,address admin,uint256 adminFee,address referrer,address payToken,uint128 basePrice,uint128 linearPriceSlope,uint128 inflectionPrice,uint32 inflectionPoint,bytes32 attestationDigest;)";

  bytes32 public constant DEPLOY_TYPE_HASH = keccak256(DEPLOY_TYPE);

  IShowtimeVerifier public immutable VERIFIER;

  // TODO: dev comment explaining this is the domain separator from the verifier that technically can change if chainId or
  // the verifier contract address change (latter can't happen if we keep the verifier hardcoded)
  bytes32 private constant DOMAIN_SEPARATOR = 0x0c3be79fa914a526eb7e8ec47178f2ca6f81e90fb14c3e335600dc3ec6fa1a6f;

  constructor(IShowtimeVerifier _verifier) {
    VERIFIER = _verifier;
  }

  function domainSeparator() external pure returns (bytes32) {
      return DOMAIN_SEPARATOR;
  }

  function encode(CreatorTokenDeploymentConfig memory _config) public pure returns (bytes memory) {
    return abi.encodePacked(
      keccak256(bytes(_config.name)),
      keccak256(bytes(_config.symbol)),
      keccak256(bytes(_config.tokenURI)),
      uint256(uint160(_config.creator)),
      _config.creatorFee,
      uint256(uint160(_config.admin)),
      _config.adminFee,
      uint256(uint160(_config.referrer)),
      uint256(uint160(address(_config.payToken))),
      uint256(_config.basePrice),
      uint256(_config.linearPriceSlope),
      uint256(_config.inflectionPrice),
      uint256(_config.inflectionPoint)
      // _config.attestationDigest
    );
  }

  function digestForDeploymentConfig(CreatorTokenDeploymentConfig memory _config) external pure returns (bytes32 _digest) {
    bytes32 _configHash = keccak256(abi.encodePacked(DEPLOY_TYPE_HASH, encode(_config)));
    _digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, _configHash));
  }

  function deployCreatorToken(
    // Attestation memory _attestation,
    CreatorTokenDeploymentConfig memory _config
    // bytes calldata _signature
  ) external returns (CreatorToken _creatorToken) {
    // bool _verified = VERIFIER.verifyAndBurn(_attestation, DEPLOY_TYPE_HASH, encode(_config), _signature);
    // if (!_verified) revert CreatorTokenFactory__DeploymentNotVerified();

    CTBondingCurve _bondingCurve =
    new CTBondingCurve(_config.basePrice, _config.linearPriceSlope, _config.inflectionPrice, _config.inflectionPoint);

    _creatorToken = new CreatorToken(
            _config.name,
            _config.symbol,
            _config.tokenURI,
            _config.creator,
            _config.creatorFee,
            _config.admin,
            _config.adminFee,
            _config.referrer,
            _config.payToken,
            _bondingCurve
        );
    emit CreatorTokenDeployed(_creatorToken, _bondingCurve, _config);
  }
}