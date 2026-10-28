import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfilePictureEvent extends ProfileEvent {
  final String avatarUrl;

  const UpdateProfilePictureEvent(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class VerifyGovtIdEvent extends ProfileEvent {
  final String idDocument;

  const VerifyGovtIdEvent(this.idDocument);

  @override
  List<Object?> get props => [idDocument];
}

class ConfirmEmailEvent extends ProfileEvent {}

class UpdatePersonalDetailsEvent extends ProfileEvent {
  final String name;
  final String email;

  const UpdatePersonalDetailsEvent({
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [name, email];
}

class UpdatePostalAddressEvent extends ProfileEvent {
  final String address;

  const UpdatePostalAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class UpdateCommunicationPreferencesEvent extends ProfileEvent {
  final bool push;
  final bool email;
  final bool sms;

  const UpdateCommunicationPreferencesEvent({
    required this.push,
    required this.email,
    required this.sms,
  });

  @override
  List<Object?> get props => [push, email, sms];
}

class UpdatePayoutMethodEvent extends ProfileEvent {
  final String method;

  const UpdatePayoutMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}

class UpdatePaymentMethodEvent extends ProfileEvent {
  final String method;

  const UpdatePaymentMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}
