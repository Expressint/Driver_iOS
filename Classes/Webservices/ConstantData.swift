//
//  ConstantData.swift
//   TenTaxi-Driver
//
//  Created by Excellent Webworld on 17/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import Foundation
import UIKit

//let helpLineNumber = "1234567890"

struct WebSupport {
    static let HelplineNumber = "0777115054"
//    static let SupportURL = "https://www.tantaxitanzania.com/page/support-tantaxi"
    static let TermsNConditionsURL = "https://www.bookaridegy.com/TermsAndCondition"
    static let PrivacyPolicyURL = "https://www.bookaridegy.com/PrivacyPolicy"
}

//Live: https://www.bookaridegy.com/Drvier_Api/
//Development: http://52.23.45.119/
struct WebserviceURLs {
    
    static let kBaseURL                                 = "http://52.23.45.119/v3/Drvier_Api/"
    static let kImageBaseURL                            = "http://52.23.45.119/"
    static let kOTPForDriverRegister                    = "OtpForRegister"
    static let kVehicalModelList                        = "TaxiModel/"
    static let kDriverRegister                          = "Register"
    static let kDriverLogin                             = "Login"
    static let kDriverChangeDutyStatusOrShiftDutyStatus = "ChangeDriverShiftStatus/"
    static let kChangePassword                          = "ChangePassword"
    static let kUpdateProfile                           = "UpdateProfile"
    static let kForgotPassword                          = "ForgotPassword"
    static let kPastBooking                             = "PastJobs"
    static let kCompany                                 = "Company"
    static let kDistrict                                = "districtList"
    static let KUpdateDriverBasicInfo                   = "UpdateDriverBasicInfo"
    static let KUpdateBankInfo                          = "UpdateBankInfo"
    static let kUpdateVehicleInfo                       = "UpdateVehicleInfo"
    static let kUpdateDocument                          = "UpdateDocs"
    static let kSubmitCompleteBooking                   = "SubmitCompleteBooking"
    static let kBookingHistory                          = "BookingHistory/"
    static let kDispatchJob                             = "DispatchJob/"
    static let kAcceptDispatchJobRequest                = "AcceptDispatchJobRequest/"
    static let kLogout                                  = "Logout/"
    static let kSubmitCompleteAdvancedBooking           = "SubmitCompleteAdvancedBooking"
    static let kChatHistory                             = "chat_history"
    static let kSubmitMultipleDropoff                   = "SubmitMultipleDropoff"
    static let kSubmitBookNowByDispatchJob              = "SubmitBookNowByDispatchJob"
    static let kSubmitBookLaterByDispatchJob            = "SubmitBookLaterByDispatchJob"
    static let kFutureBooking                            = "FutureBooking/"
    static let kMyDispatchJob                           = "MyDispatchJob/"
    static let kGetDriverProfile                        = "GetDriverProfile/"
    static let kGetDistaceFromBackend                   = "FindDistance/"
    static let kCurrentBooking                          = "CurrentBooking/"
    static let kAddNewCard                              = "AddNewCard"
    static let kCards                                   = "Cards/"
    static let kDeleteAccount                           = "deleteAccount/"//
    static let kAddMoney                                = "AddMoney"
    static let kTransactionHistory                      = "TransactionHistory/"
    static let kSendMoney                               = "SendMoney"
    static let kQRCodeDetails                           = "QRCodeDetails"
    static let kRemoveCard                              = "RemoveCard/"
    static let kTickpay                                 = "Tickpay"
    static let kGetTickpayRate                          = "GetTickpayRate"
    static let kTickpayInvoice                          = "TickpayInvoice"
    static let kNEWSUrl                                 = "https://newsapi.org/v2/top-headlines?sources=google-news&apiKey="
    static let kNEWSApiKey                              = "90727bb768584fd7b64b66c9190921e0"
    static let kReviewRating                            = "ReviewRating"
    static let kWeeklyEarnings                          = "WeeklyEaringIOS/"
    static let kTransferMoneyToBank                     = "TransferToBank"
    static let kInit                                    = "Init/"
    static let kGetEstimateFare                         = "GetEstimateFare"
    static let kGetTaxiModelPricing                     = "TaxiModelForPricing"
    static let kGetFareEstimateWithKM                   = "GetEstimateFareWithKM"
    static let kCancelTrip                              = "CancelTrip"
    static let kManageTripToDestination                 = "ManageTripToDestination"
    static let kManageShareRideFlag                     = "ManageShareRideFlag/"
    static let kShareRide                               = "ShareRide/"
    static let kTrackRunningTrip                        = "TrackRunningTrip/"
    static let kPrivateMeterBooking                     = "PrivateMeterBooking"
    static let kDriverEarningReport                     = "driverEarningReport"
    static let kHelpOptions                             = "HelpOptions"
    static let kHelp                                    = "Help"
    //Tour
    static let RentalCurrentBooking                    = "RentalCurrentBooking"
    static let kSubmitCompleteRentalBooking           = "SubmitCompleteRentalBooking"
    static let kRentalReviewRating                     = "RentalReviewRating"
    static let kRentalHistory                           = "RentalBookingHistory"

//    https://www.tantaxitanzania.com/Drvier_Api/FeedbackList/9
    static let kFeedbackList                     = "FeedbackList/"
}

struct OTPEmail {
    static let kEmail = "Email"
}

struct OTPCodeStruct {
    static let kOTPCode = "OTPCode"
    static let kCompanyList = "company"
}


struct savedDataForRegistration {
    static let kKeyEmail                             = "Email"
    static let kKeyOTP                               = "OTP"
    static let kKeyAllUserDetails                    = "CompleteUserDetails"
    static let kModelDetails                         = "CompleteModelDetails"
    static let kPageNumber                           = "PageNumber"
}

struct profileKeys {
    static let kDriverId = "DriverId"
    static let kRejectBy = "RejectBy"
    static let kCarModel = "CarModel"
    static let kCarCompany = "CarCompany"
    static let kCompanyID = "CompanyId"
}

struct RegistrationProfileKeys {
    static let kKeyEmail = "email"
    static let kKeyFullName = "fullName"
    static let kKeyDOB = "DOB"
    static let kKeyMobileNumber = "mobileNumber"
    static let kKeyPassword = "password"
    static let kKeyAddress = "address"
    static let kKeyDistrict = "district"
    static let kKeyPostCode = "postCode"
    static let kKeyState = "state"
    static let kKeyCountry = "country"
    static let kKeyInviteCode = "inviteCode"
}

struct driverProfileKeys {
    static let kKeyDriverProfile = "driverProfile"
    static let kKeyIsDriverLoggedIN = "isDriverLoggedIN"
    static let kKeyShowTickPayRegistrationScreen = "showTickPayRegistrationKey"
}

//struct driverTripToDestinationKeys
//{
//    static let kKeyFirstDestination = "FirstDestination"
//    static let kKeySecondDestination = "SecondDestination"
//    static let kKeyIsBothDestinationSelected = "isBothDestinationSelected"
//    static let kKeyIsFirstDestinationSelected = "isFirstDestinationSelected"
//    static let kKeyIsSecondDestinationSelected = "isSecondDestinationSelected"
//}

struct RegistrationFinalKeys {
    
    
    static let kEmail = "Email"                          // Done
    
    static let kCompanyID = "CompanyId" // Done
    // ------------------------------------------------------------
    static let kKeyDOB = "DOB"

    static let kMobileNo = "MobileNo"// Done
    static let kFirstname = "Firstname"// Done
    static let kLastName = "Lastname"// Done
    static let kGender = "Gender"// Done
    static let kPassword = "Password"// Done
    static let kAddress = "Address"// Done
    static let kDistrict = "District"// Done
    
    static let kSuburb = "Suburb"// Done
    
    static let kBankBranch = "BankBranch"// Done
    static let kCity = "City"// Done
    static let kState = "State"// Done
    static let kCountry = "Country"// Done
    static let kZipcode = "Zipcode"
    static let kDriverImage = "DriverImage" //Done
    static let kDriverLicence = "DriverLicence" //Done
    static let kDriverLicenseBackside = "DriverLicenseBackside"
    static let kAccreditationCertificate = "AccreditationCertificate" //Done
    static let kDriverLicenceExpiryDate = "DriverLicenseExpire" //Done
    static let kAccreditationCertificateExpiryDate = "AccreditationCertificateExpire" //Done
    static let kbankHolderName = "AccountHolderName"
    static let kBankName = "BankName"// Done
    static let kBankAccountNo = "BankAcNo"// Done
    static let kABN = "ABN"// Done
    static let kBSB = "BSB"// Done
    static let kServiceDescription = "Description"
    static let kVehicleColor = "Color" //Done
    static let kCarRegistrationCertificate = "CarRegistrationCertificate" //Done
    static let kPoliceClearanceCertificate = "PoliceClearance" //Done
    static let kFitnessCertificate = "Fitness" //Done
    static let kRoadServiceCertificate = "RoadService" //Done
    static let kVehicleInsuranceCertificate = "VehicleInsuranceCertificate" //Done
    static let kCarRegistrationExpiryDate = "RegistrationCertificateExpire" //Done
    static let kPoliceClearanceExpiryDate = "PoliceClearanceCertificateExpire" //Done
    static let kFitnessExpiryDate = "FitnessCertificateExpire" //Done
    static let kRoadServiceExpiryDate = "RoadServiceExpire" //Done
    static let kVehicleInsuranceCertificateExpiryDate = "VehicleInsuranceCertificateExpire" //Done
    static let kReferralCode = "ReferralCode" //Done
    static let kLat = "Lat"//Done
    static let kLng = "Lng"//Done
    static let kCarThreeTypeName = "CarTypeName"

    
    //         String DRIVER_REGISTER_PARAM_VEHICLE_IMAGE = "VehicleImage";
    //        String DRIVER_REGISTER_PARAM_VEHICLE_RIGISTRATION_NO = "VehicleRegistrationNo";
    //        String DRIVER_REGISTER_PARAM_VEHICLE_MODEL_NAME = "VehicleModelName";
    //        String DRIVER_REGISTER_PARAM_VEHICLE_MAKE = "CompanyModel";
    //        String DRIVER_REGISTER_PARAM_VEHICLE_TYPE = "VehicleClass";
    //        String DRIVER_REGISTER_PARAM_NO_OF_PASSENGER = "NoOfPassenger";
    
    
    static let kVehicleRegistrationNo = "VehicleRegistrationNo" //Done
    static let kVehicleImage = "VehicleImage" //Done
    static let kCompanyModel = "CompanyModel" //Done
    static let kVehicleModelName = "VehicleModelName" //Done
    static let kNumberOfPasssenger = "NoOfPassenger" //Done
    static let kVehicleClass = "VehicleClass" //Done
   
}

//Live: https://www.bookaridegy.com:8080
//Development: http://52.23.45.119:8080
struct socketApiKeys {
    
    static let kSocketBaseURL = "http://52.23.45.119:8080"
 
    static let kUpdateDriverLocation = "UpdateDriverLatLong"
    static let kReceiveBookingRequest = "AriveBookingRequest"
    static let kRejectBookingRequest = "ForwardBookingRequestToAnother"
    static let kAcceptBookingRequest = "AcceptBookingRequest"
    static let kUpdateDropoffLocation = "UpdateDropoffLocationNotification"
    static let kCurrentLat = "CurLat"
    static let kCurrentLong = "CurLong"
    static let kPassengerId = "PassengerId"
    static let kPickUpLat = "PickupLat"
    static let kPickUpLong = "PickupLong"
    static let SOS = "SOS"
    static let kLat = "Lat"
    static let kLong = "Long"
    static let kBookingId = "BookingId"
    static let kBookingType = "BookingType"
    static let kAdvanceBookingID = "BookingId"
    static let kUserType = "UserType"
    static let kGetBookingDetailsAfterBookingRequestAccepted = "BookingInfo"
    static let kPickupPassengerByDriver = "PickupPassenger"
    static let kDriverArrivedCheck = "DriverArrivedCheck"
    static let kOnDriverArrivedCheck = "DriverArrivedCheck"
    static let kStartHoldTrip = "StartHoldTrip"
    static let kEndHoldTrip = "EndHoldTrip"
    static let kDriverCancelTripNotification = "DriverCancelTripNotification"
    static let kSendDriverLocationRequestByPassenger = "DriverLocationWithETA"
    static let kAriveAdvancedBookingRequest = "AriveAdvancedBookingRequest"
    static let kForwardAdvancedBookingRequestToAnother = "ForwardAdvancedBookingRequestToAnother"
    static let kAcceptAdvancedBookingRequest = "AcceptAdvancedBookingRequest"
    static let kAdvancedBookingPickupPassenger = "AdvancedBookingPickupPassenger"
    static let kAdvancedBookingStartHoldTrip = "AdvancedBookingStartHoldTrip"
    static let kAdvancedBookingEndHoldTrip = "AdvancedBookingEndHoldTrip"
    static let kAdvancedBookingCompleteTrip = "AdvancedBookingCompleteTrip"
    static let kAdvancedBookingDriverCancelTripNotification = "AdvancedBookingDriverCancelTripNotification"
    static let kAdvancedBookingInfo = "AdvancedBookingInfo"
    static let kAdvancedBookingPickupPassengerNotification = "AdvancedBookingPickupPassengerNotification"
    static let kGetDriverLocation = "GetDriverLocation"
    static let kBookLaterDriverNotify = "BookLaterDriverNotify"
    static let kReceiveMoneyNotify = "ReceiveMoneyNotify"
    static let kStartTripTimeError = "StartTripTimeError"
    static let kAskForTips = "AskForTips"
    static let KWaitingTimeToDispatchere = "notify_waiting_time_to_dispatcher"
    static let kReceiveTipsToDriver = "ReceiveTipsToDriver"
    static let kAskForTipsForBookLater = "AskForTipsForBookLater"
    static let kReceiveTipsToDriverForBookLater = "ReceiveTipsToDriverForBookLater"
    static let connectDriverForChat = "connectDriverForChat"
    static let sendMessage = "sendMessage"
    static let receiveMessage = "receive_message"
    static let starTyping = "start_typing"
    static let stopTyping = "stop_typing"
    static let DriverTyping = "is_typing"
    static let DriverStopTyping = "is_stop_typing"
    
    
    //MARK: - Tour
    static let NewRequestForTour = "ArriveRentalBookingRequest"
    static let ForwardRentalBookingRequestToAnother = "ForwardRentalBookingRequestToAnother"
    static let AcceptRentalBooking = "AcceptRentalBookingRequest"
    static let RentalBookingInfo = "RentalBookingInfo"
    static let RentalDriverArrivedCheck = "RentalDriverArrivedCheck"
    static let PickupRentalPassenger = "PickupRentalPassenger"
    static let StartRentalTrip = "StartRentalTrip"
    static let StartRentalTripError = "StartRentalTripTimeError"
    static let RentalUpdateDriverLocation = "UpdateRentalDriverLatLong"
    static let CancelRentalTripNotification = "DriverCancelRentalTripNotification"
    static let OntheWayForRentalAdvancedTrip = "OntheWayForRentalAdvancedTrip"
    static let StartRentalTripTimeError = "StartRentalTripTimeError"
    
}

struct appName {
    static let kAPPName = "App Name".localized
//    "TanTaxi Driver"
    static let kAPPUrl = "itms-apps://itunes.apple.com/app/apple-store/id1541299485?mt=8"
    static let kAPPUrlAndroid = "https://play.google.com/store/apps/details?id=com.bookride.driver"
    static let kAPPUrliOS = "https://apps.apple.com/in/app/bookaridegy-driver/id1541299485"
    static let appURLAndroid = "https://play.google.com/store/apps/details?id=com.bookride.passenger"
    static let appURLiOS = "https://apps.apple.com/in/app/bookaridegy/id1541296701"
}

struct AppTextfieldTags {
    static let SecureTextTag = 111
}

//Email,MobileNo,Fullname,Gender,Password,Address,ReferralCode,Lat,Lng,
//CarModel,
//DriverLicence,CarRegistration,AccreditationCertificate,VehicleInsuranceCertificate


struct nsNotificationKeys {
    
    static let kBookingTypeBookNow = "BookingTypeBookNow"
    static let kBookingTypeBookLater = "BookingTypeBookLater"
}

struct tripStatus {
    static let kisTripContinue = "isTripContinue"
    static let kisRequestAccepted = "isRequestAccepted"
}

struct holdTripStatus {
    static let kIsTripisHolding = "IsTripisHolding"
    
}

struct meterStatus {
    static let kIsMeterOnHolding = "meterOnHold"
    static let kIsMeterStart = "meterOnStart"
    static let kIsMeterStop = "meterOnStop"
}

struct walletAddCards {
    // DriverId,CardNo,Cvv,Expiry,Alias (CarNo : 4444555511115555,Expiry:09/20)
    static let kCardNo = "CardNo"
    static let kCVV = "Cvv"
    static let kExpiry = "Expiry"
    static let kAlias = "Alias"

}

struct walletAddMoney {
    // DriverId,Amount,CardId
    static let kAmount = "Amount"
    static let kCardId = "CardId"
}

struct  walletSendMoney {
    // QRCode,SenderId,Amount
    
    static let kQRCode = "QRCode"
    static let kAmount = "Amount"
    static let kSenderId = "SenderId"
}

struct passengerData {
    static let kPassengerMobileNunber = "PassengerMobileNunber"
}



//-------------------------------------------------------------
// MARK: - Device Types
//-------------------------------------------------------------


struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6_7        = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P_7P      = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

struct Version
{
    static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
    static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
    static let iOS10 = (Version.SYS_VERSION_FLOAT >= 10.0 && Version.SYS_VERSION_FLOAT < 11.0)
    static let iOS11 = (Version.SYS_VERSION_FLOAT >= 11.0 && Version.SYS_VERSION_FLOAT < 12.0)
}





