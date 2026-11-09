package com.nebulagame.rotaterings.rotate_rings.levels

import com.nebulagame.rotaterings.rotate_rings.model.*
import java.util.Random
import kotlin.math.PI
import kotlin.math.atan2

object LevelCatalog {
    const val TOTAL_LEVELS = 200

    private val cachedLevels = mutableMapOf<Int, LevelData>()

    fun getLevel(levelNumber: Int): LevelData {
        val n = levelNumber.coerceIn(1, TOTAL_LEVELS)
        return cachedLevels.getOrPut(n) { generateLevel(n) }.clone()
    }

    private fun generateLevel(n: Int): LevelData {
        return when {
            n == 65 -> buildLevel65()
            n <= 20 -> buildTier1(n)
            n <= 40 -> buildTier2(n)
            n <= 60 -> buildTier3(n)
            n <= 80 -> buildTier4(n)
            n <= 100 -> buildTier5(n)
            n <= 130 -> buildTier6(n)
            n <= 160 -> buildTier7(n)
            n <= 180 -> buildTier8(n)
            else -> buildTier9(n)
        }
    }

    private fun buildTier1(n: Int): LevelData {
        val rng = Random((n * 101 + 7).toLong())
        val rings = mutableListOf<Ring>()
        val joints = mutableListOf<Joint>()

        if (n <= 8) {
            rings.add(
                Ring(
                    id = "r1", cx = 200f, cy = 300f, radius = 80f,
                    colorHex = 0xFFFF9233, shapeType = RingShapeType.C_LOCK,
                    gapStartAngle = 0.0, currentAngle = rng.nextDouble() * 2 * PI,
                    hasAcorn = true
                )
            )
            joints.add(
                Joint(
                    id = "j1", type = JointType.PIN, px = 200f, py = 220f,
                    ringIdA = "r1", colorHex = 0xFF4A5568, angleOnA = -PI / 2
                )
            )
        } else {
            rings.add(Ring(id = "r1", cx = 145f, cy = 300f, radius = 68f, colorHex = 0xFF34A9F4, gapStartAngle = 0.0, currentAngle = rng.nextDouble() * 2 * PI, hasAcorn = true))
            rings.add(Ring(id = "r2", cx = 255f, cy = 300f, radius = 68f, colorHex = 0xFF9E4FE8, gapStartAngle = 0.0, currentAngle = rng.nextDouble() * 2 * PI))
            joints.add(Joint(id = "j1_2", px = 200f, py = 300f, ringIdA = "r1", ringIdB = "r2", colorHex = 0xFF4A5568, angleOnA = 0.0, angleOnB = PI))
        }

        return LevelData(n, "Căn Bản $n", "Làm Quen", 1, rings, joints, rings.size * 2, 30)
    }

    private fun buildTier2(n: Int): LevelData {
        val rng = Random((n * 203 + 19).toLong())
        val rings = mutableListOf<Ring>()
        val joints = mutableListOf<Joint>()
        val count = if (n < 32) 2 else 3

        for (i in 0 until count) {
            rings.add(
                Ring(
                    id = "r${i + 1}", cx = 200f, cy = 190f + (i * 110f), radius = 55f,
                    colorHex = if (i % 2 == 0) 0xFF34A9F4 else 0xFF78C826,
                    gapStartAngle = 0.3 * i, currentAngle = rng.nextDouble() * 2 * PI,
                    hasAcorn = (i % 2 == 0)
                )
            )
        }
        for (i in 0 until count - 1) {
            joints.add(
                Joint(
                    id = "j_${i + 1}_${i + 2}", px = 200f, py = 245f + (i * 110f),
                    ringIdA = "r${i + 1}", ringIdB = "r${i + 2}", colorHex = 0xFF4A5568,
                    angleOnA = PI / 2, angleOnB = -PI / 2
                )
            )
        }
        return LevelData(n, "Khe Hở Kép $n", "Hai Vòng", 2, rings, joints, count * 2 + 1, 35)
    }

    private fun buildTier3(n: Int): LevelData {
        val rng = Random((n * 307 + 31).toLong())
        val rings = mutableListOf<Ring>()
        val joints = mutableListOf<Joint>()
        val centers = listOf(Pair(145f, 230f), Pair(255f, 230f), Pair(200f, 360f))

        for (i in 0 until 3) {
            rings.add(
                Ring(
                    id = "r${i + 1}", cx = centers[i].first, cy = centers[i].second, radius = 58f,
                    colorHex = 0xFFFF9233 + (i * 0x00112233),
                    shapeType = if (i % 2 == 0) RingShapeType.C_LOCK else RingShapeType.D_RING,
                    gapStartAngle = 0.5 * i, currentAngle = rng.nextDouble() * 2 * PI,
                    hasAcorn = (i == 0)
                )
            )
        }
        joints.add(createJoint("j1_2", rings[0], rings[1], 0xFF4A5568))
        joints.add(createJoint("j2_3", rings[1], rings[2], 0xFF4A5568))
        return LevelData(n, "Khóa C-Lock $n", "C-Lock & D-Ring", 3, rings, joints, 8, 45)
    }

    private fun buildTier4(n: Int): LevelData {
        val rng = Random((n * 409 + 43).toLong())
        val rings = mutableListOf<Ring>()
        val joints = mutableListOf<Joint>()
        for (i in 0 until 5) {
            rings.add(
                Ring(
                    id = "r${i + 1}", cx = if (i % 2 == 0) 150f else 250f, cy = 160f + (i * 75f), radius = 54f,
                    colorHex = 0xFF9E4FE8, shapeType = RingShapeType.INTERLOCKED_CHAIN,
                    gapStartAngle = 0.4 * i, currentAngle = rng.nextDouble() * 2 * PI,
                    hasAcorn = (i % 2 == 1)
                )
            )
        }
        for (i in 0 until 4) {
            joints.add(createJoint("j_${i + 1}_${i + 2}", rings[i], rings[i + 1], 0xFF4A5568))
        }
        return LevelData(n, "Chuỗi Mắt Xích $n", "Mắt Xích Đan Xen", 3, rings, joints, 10, 50)
    }

    private fun buildLevel65(): LevelData {
        val rings = mutableListOf(
            Ring("r1", 155f, 150f, 52f, colorHex = 0xFFFF9233, gapStartAngle = 0.0, currentAngle = -0.8, hasAcorn = true),
            Ring("r2", 230f, 215f, 52f, colorHex = 0xFF34A9F4, gapStartAngle = 0.0, currentAngle = 1.2),
            Ring("r3", 170f, 305f, 52f, colorHex = 0xFF9E4FE8, gapStartAngle = 0.0, currentAngle = -0.6, hasAcorn = true),
            Ring("r4", 265f, 335f, 52f, colorHex = 0xFF2EA868, gapStartAngle = 0.0, currentAngle = 2.1),
            Ring("r5", 110f, 385f, 52f, colorHex = 0xFFE84545, gapStartAngle = 0.0, currentAngle = -2.3),
            Ring("r6", 195f, 420f, 52f, colorHex = 0xFF78C826, gapStartAngle = 0.0, currentAngle = 0.5, hasAcorn = true),
            Ring("r7", 155f, 510f, 52f, colorHex = 0xFF3B72DE, gapStartAngle = 0.0, currentAngle = 0.0)
        )
        val joints = mutableListOf(
            createJoint("j1_2", rings[0], rings[1], 0xFF34A9F4),
            createJoint("j2_3", rings[1], rings[2], 0xFF9E4FE8),
            createJoint("j3_5", rings[2], rings[4], 0xFFE84545),
            createJoint("j3_6", rings[2], rings[5], 0xFF9E4FE8),
            createJoint("j6_4", rings[5], rings[3], 0xFF78C826),
            createJoint("j6_7", rings[5], rings[6], 0xFF78C826)
        )
        return LevelData(65, "Mắt Xích Kỳ Diệu 65", "Nebula Classic", 4, rings, joints, 14, 60)
    }

    private fun buildTier5(n: Int): LevelData {
        val rings = mutableListOf(
            Ring("r1", 200f, 300f, 50f, colorHex = 0xFFFF9233, gapStartAngle = 0.0, hasAcorn = true),
            Ring("r2", 200f, 300f, 85f, colorHex = 0xFF34A9F4, gapStartAngle = 0.5),
            Ring("r3", 200f, 300f, 120f, colorHex = 0xFF9E4FE8, gapStartAngle = 1.0)
        )
        val joints = mutableListOf(
            Joint("j1_2", px = 200f, py = 233f, ringIdA = "r1", ringIdB = "r2", colorHex = 0xFF4A5568, angleOnA = -PI / 2, angleOnB = -PI / 2),
            Joint("j2_3", px = 200f, py = 198f, ringIdA = "r2", ringIdB = "r3", colorHex = 0xFF4A5568, angleOnA = -PI / 2, angleOnB = -PI / 2)
        )
        return LevelData(n, "Ba Vòng Hòa Nhịp $n", "Ba Vòng", 3, rings, joints, 8, 45)
    }

    private fun buildTier6(n: Int): LevelData {
        val rings = mutableListOf<Ring>()
        val joints = mutableListOf<Joint>()
        val count = 4
        for (i in 0 until count) {
            val a = (2 * PI / count) * i - PI / 2
            val cx = 200f + (85f * kotlin.math.cos(a)).toFloat()
            val cy = 300f + (85f * kotlin.math.sin(a)).toFloat()
            rings.add(Ring("r${i + 1}", cx, cy, 50f, colorHex = 0xFFFF9233, gapStartAngle = 0.5 * i, hasAcorn = (i == 0)))
        }
        for (i in 0 until count) {
            joints.add(createJoint("j_${i + 1}_${(i + 1) % count + 1}", rings[i], rings[(i + 1) % count], 0xFF4A5568))
        }
        return LevelData(n, "Khung Đa Giác $n", "Khóa Hình Học", 4, rings, joints, 10, 60)
    }

    private fun buildTier7(n: Int): LevelData {
        val rings = mutableListOf<Ring>()
        val joints = mutableListOf<Joint>()
        val center = Ring("r_c", 200f, 300f, 60f, colorHex = 0xFFFF9233, gapStartAngle = 0.0, hasAcorn = true)
        rings.add(center)
        for (i in 0 until 3) {
            val a = (2 * PI / 3) * i - PI / 2
            val cx = 200f + (95f * kotlin.math.cos(a)).toFloat()
            val cy = 300f + (95f * kotlin.math.sin(a)).toFloat()
            val r = Ring("r_o_${i + 1}", cx, cy, 54f, colorHex = 0xFF34A9F4, gapStartAngle = 0.4 * i)
            rings.add(r)
            joints.add(createJoint("j_c_$i", center, r, 0xFF4A5568))
        }
        return LevelData(n, "Khóa Đa Tầng $n", "Nhiều Tầng", 4, rings, joints, 12, 65)
    }

    private fun buildTier8(n: Int): LevelData {
        val rings = mutableListOf<Ring>()
        val joints = mutableListOf<Joint>()
        val centers = listOf(Pair(130f, 200f), Pair(270f, 200f), Pair(200f, 300f), Pair(130f, 400f), Pair(270f, 400f))
        for (i in 0 until 5) {
            rings.add(Ring("r${i + 1}", centers[i].first, centers[i].second, 52f, colorHex = 0xFF78C826, gapStartAngle = 0.3 * i, hasAcorn = (i == 2)))
        }
        joints.add(createJoint("j1_3", rings[0], rings[2], 0xFF4A5568))
        joints.add(createJoint("j2_3", rings[1], rings[2], 0xFF4A5568))
        joints.add(createJoint("j4_3", rings[3], rings[2], 0xFF4A5568))
        joints.add(createJoint("j5_3", rings[4], rings[2], 0xFF4A5568))
        return LevelData(n, "Khóa Lai Tạo $n", "Kết Hợp", 5, rings, joints, 14, 75)
    }

    private fun buildTier9(n: Int): LevelData {
        val rings = mutableListOf<Ring>()
        val joints = mutableListOf<Joint>()
        for (i in 0 until 6) {
            val cx = if (i % 2 == 0) 140f else 260f
            val cy = 180f + (i * 60f)
            rings.add(Ring("r${i + 1}", cx, cy, 50f, colorHex = 0xFFE84545, gapStartAngle = 0.4 * i, hasAcorn = (i % 2 == 1)))
        }
        for (i in 0 until 5) {
            joints.add(createJoint("j_${i + 1}_${i + 2}", rings[i], rings[i + 1], 0xFF4A5568))
        }
        return LevelData(n, "Bậc Thầy $n", "Master", 5, rings, joints, 16, 90)
    }

    private fun createJoint(id: String, rA: Ring, rB: Ring, color: Long): Joint {
        val mx = (rA.cx + rB.cx) / 2f
        val my = (rA.cy + rB.cy) / 2f
        val aOnA = atan2((my - rA.cy).toDouble(), (mx - rA.cx).toDouble())
        val aOnB = atan2((my - rB.cy).toDouble(), (mx - rB.cx).toDouble())
        return Joint(id, JointType.SLEEVE, mx, my, rA.id, rB.id, color, aOnA, aOnB)
    }
}
