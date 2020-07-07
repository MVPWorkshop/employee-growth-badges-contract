const EmployeeRecognitionContract = artifacts.require(
  "EmployeeRecognitionContract"
);

// @TODO Extract from .env
module.exports = function (deployer) {
  deployer.deploy(
    EmployeeRecognitionContract,
    process.env.TOKEN_METADATA_URL
  );
};
