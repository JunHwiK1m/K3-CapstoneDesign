package com.leafy.security.oauth2;

import com.leafy.entity.Provider;
import com.leafy.entity.Role;
import com.leafy.entity.User;
import com.leafy.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;

    @Override
    @Transactional
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);

        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        Map<String, Object> attributes = oAuth2User.getAttributes();

        OAuth2UserInfo oAuth2UserInfo = OAuth2UserInfoFactory.getOAuth2UserInfo(registrationId, attributes);

        User user = saveOrUpdate(oAuth2UserInfo, Provider.valueOf(registrationId.toUpperCase()));

        return new CustomOAuth2User(user, attributes);
    }

    private User saveOrUpdate(OAuth2UserInfo oAuth2UserInfo, Provider provider) {
        Optional<User> userOptional = userRepository.findByEmail(oAuth2UserInfo.getEmail());
        User user;

        if (userOptional.isPresent()) {
            user = userOptional.get();
            user.updateProfile(oAuth2UserInfo.getName(), oAuth2UserInfo.getImageUrl());
        } else {
            user = User.builder()
                    .email(oAuth2UserInfo.getEmail())
                    .nickname(oAuth2UserInfo.getName())
                    .profileImg(oAuth2UserInfo.getImageUrl())
                    .provider(provider)
                    .providerId(oAuth2UserInfo.getId())
                    .build();
            user.addRole(Role.USER);
        }

        return userRepository.save(user);
    }
}
