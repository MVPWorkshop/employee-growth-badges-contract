const EmployeeRecognitionContract = artifacts.require(
  "EmployeeRecognitionContract"
);

// @TODO Extract from .env
module.exports = function (deployer) {
  deployer.deploy(
    EmployeeRecognitionContract,
    "http://localhost:3001/api/metadata/token"
  );
};
