package com.nebulagame.rotaterings.rotate_rings.model

enum class JointType {
    SLEEVE,
    PIN,
    CHAIN_LINK,
    PIVOT
}

data class Joint(
    val id: String,
    val type: JointType = JointType.SLEEVE,
    val px: Float,
    val py: Float,
    val ringIdA: String,
    val ringIdB: String? = null,
    val colorHex: Long,
    val angleOnA: Double,
    val angleOnB: Double? = null,
    val isSilver: Boolean = false,
    var detachedFromA: Boolean = false,
    var detachedFromB: Boolean = false,
    var isReleased: Boolean = false,
    var releaseAnimation: Float = 0.0f
) {
    fun isHoldingRing(ringId: String, isOtherRingFreed: Boolean = false): Boolean {
        if (isReleased) return false
        if (type == JointType.PIN) {
            if (ringIdA == ringId) return !detachedFromA
            return false
        }
        if (ringIdA == ringId) {
            if (detachedFromA) return false
            if (isOtherRingFreed || detachedFromB) return false
            return true
        }
        if (ringIdB == ringId) {
            if (detachedFromB) return false
            if (isOtherRingFreed || detachedFromA) return false
            return true
        }
        return false
    }

    fun updateReleaseState() {
        if (detachedFromA || detachedFromB) {
            isReleased = true
        }
    }
}
