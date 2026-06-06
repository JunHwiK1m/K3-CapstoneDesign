package com.narae.security.oauth2;

import com.narae.entity.Provider;
import com.narae.exception.BusinessException;
import com.narae.exception.ErrorCode;

import java.util.Map;

public class OAuth2UserInfoFactory {

    public static OAuth2UserInfo getOAuth2UserInfo(String registrationId, Map<String, Object> attributes) {
        if (registrationId.equalsIgnoreCase(Provider.GOOGLE.getRegistrationId())) {
            return new GoogleOAuth2UserInfo(attributes);
        } else if (registrationId.equalsIgnoreCase(Provider.NAVER.getRegistrationId())) {
            return new NaverOAuth2UserInfo(attributes);
        } else if (registrationId.equalsIgnoreCase(Provider.KAKAO.getRegistrationId())) {
            return new KakaoOAuth2UserInfo(attributes);
        } else {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE);
        }
    }
}
