package com.nebulagame.rotaterings.rotate_rings

import com.nebulagame.rotaterings.rotate_rings.levels.LevelCatalog
import com.nebulagame.rotaterings.rotate_rings.physics.GeometryMath
import com.nebulagame.rotaterings.rotate_rings.physics.UntangleEngine
import com.nebulagame.rotaterings.rotate_rings.solver.PuzzleSolver
import org.junit.Assert.*
import org.junit.Test
import kotlin.math.PI

class RotateRingsKotlinTest {

    @Test
    fun testAngleNormalization() {
        assertEquals(0.0, GeometryMath.normalizeAngle(0.0), 0.001)
        assertEquals(0.0, GeometryMath.normalizeAngle(2 * PI), 0.001)
        assertEquals(4.7123, GeometryMath.normalizeAngle(-PI / 2), 0.001)
    }

    @Test
    fun testAll200Levels() {
        assertEquals(200, LevelCatalog.TOTAL_LEVELS)
        for (i in 1..200) {
            val lvl = LevelCatalog.getLevel(i)
            assertEquals(i, lvl.levelNumber)
            assertTrue(lvl.rings.isNotEmpty())
            assertTrue(lvl.targetMoves > 0)
        }
    }

    @Test
    fun testLevel65Data() {
        val lvl = LevelCatalog.getLevel(65)
        assertEquals(65, lvl.levelNumber)
        assertEquals(7, lvl.rings.size)
        assertEquals(6, lvl.joints.size)
        assertTrue(lvl.rings.any { it.hasAcorn })
    }

    @Test
    fun testSolverAndUntangleEngine() {
        val lvl = LevelCatalog.getLevel(1)
        val hint = PuzzleSolver.findNextMove(lvl)
        assertNotNull(hint)
        assertTrue(hint!!.message.isNotEmpty())

        // Align gap with joint
        val ring = lvl.rings[0]
        val joint = lvl.joints[0]
        ring.currentAngle = GeometryMath.normalizeAngle(joint.angleOnA - ring.gapStartAngle - (ring.gapSweep / 2.0))

        val result = UntangleEngine.checkAndReleaseCascade(lvl)
        assertTrue(result.freedRings.isNotEmpty())
        assertTrue(result.puzzleComplete)
    }
}
