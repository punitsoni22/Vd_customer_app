enum ApiEndpoint {
  login('/login'),
  logout('/logout'),
  verifyOTP('/verifyOTP'),
  addEditCart('/addEditCart'),
  getSpecificUser('/getSpecificUser'),
  getLatestCartByUserId('/getLatestCartByUserId'),
  getSpecificOrdersAssignment('/getSpecificOrdersAssignment');
 

  final String path;

  const ApiEndpoint(this.path);

  String get fullPath => path;
}
