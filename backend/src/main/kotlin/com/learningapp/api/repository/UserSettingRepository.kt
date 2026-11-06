package com.learningapp.api.repository

import com.learningapp.api.entity.UserSetting
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
interface UserSettingRepository : JpaRepository<UserSetting, UUID>
