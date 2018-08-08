import Foundation
/**
 * FAST intends for "Features from Accelerated Segment Test". This method
 * performs a point segment test corner detection. The segment test
 * criterion operates by considering a circle of sixteen pixels around the
 * corner candidate p. The detector classifies p as a corner if there exists
 * a set of n contiguous pixelsin the circle which are all brighter than the
 * intensity of the candidate pixel Ip plus a threshold t, or all darker
 * than Ip − t.
 *
 *       15 00 01
 *    14          02
 * 13                03
 * 12       []       04
 * 11                05
 *    10          06
 *       09 08 07
 *
 * For more reference:
 * http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.60.3991&rep=rep1&type=pdf
 */


class FAST{
    // FindCorners - Finds corners coordinates on the graysacaled image.
    func findCorners(pixels:[Int], width:Int, height:Int, threshold:Int)-> [CGPoint] {
        var circleOffsets = getCircleOffsets(width)
        var circlePixels: [Int] = []
        var corners :[CGPoint] = []
        
        // When looping through the image pixels, skips the first three lines from
        // the image boundaries to constrain the surrounding circle inside the image
        // area.
        
        for i in 3...height-3 {
            
            for j in  3...width-3 {
                let w = i*width + j
                let p = pixels[w]
                
                // Loops the circle offsets to read the pixel value for the sixteen
                // surrounding pixels.
                for k in 0 ... 15{
                    circlePixels[k] = pixels[w+circleOffsets[k]]
                }
                
                if isCorner(p, circlePixels, threshold) {
                    // The pixel p is classified as a corner, as optimization increment j
                    // by the circle radius 3 to skip the neighbor pixels inside the
                    // surrounding circle. This can be removed without compromising the
                    // result.
                    let corner = CGPoint(x:j,y:i)
                    corners.append(corner)
//                    corners = append(corners, j, i)
//                    j += 3
                }
            }
        }
        
        return corners
    }
    
    /**
     * Checks if the circle pixel is within the corner of the candidate pixel p
     * by a threshold.
     */
    func isCorner(_ p:Int,_ circlePixels:[Int],_ threshold:Int)-> Bool {
        if isTriviallyExcluded(circlePixels, p, threshold) {
            return false
        }
        
        for x in 0...15{
            var darker = true
            var brighter = true
            
            for y in 0...8 {
                let circlePixel = circlePixels[(x+y)&15]
                
                if !isBrighter(p, circlePixel, threshold) {
                    brighter = false
                    if !darker {
                        break
                    }
                }
                
                if !isDarker(p, circlePixel, threshold) {
                    darker = false
                    if !brighter {
                        break
                    }
                }
            }
            
            if brighter || darker {
                return true
            }
        }
        
        return false
    }
    
    /**
     * Fast check to test if the candidate pixel is a trivially excluded value.
     * In order to be a corner, the candidate pixel value should be darker or
     * brighter than 9-12 surrounding pixels, when at least three of the top,
     * bottom, left and right pixels are brighter or darker it can be
     * automatically excluded improving the performance.
     */
    func isTriviallyExcluded(_ circlePixels:[Int], _ p :Int,_ threshold :Int)-> Bool {
        var count = 0
        let circleBottom = circlePixels[8]
        let circleLeft = circlePixels[12]
        let circleRight = circlePixels[4]
        let circleTop = circlePixels[0]
        
        if isBrighter(circleTop, p, threshold) {
            count += 1
        }
        if isBrighter(circleRight, p, threshold) {
            count += 1
        }
        if isBrighter(circleBottom, p, threshold) {
            count += 1
        }
        if isBrighter(circleLeft, p, threshold) {
            count += 1
        }
        
        if count < 3 {
            count = 0
            if isDarker(circleTop, p, threshold) {
                count += 1
            }
            if isDarker(circleRight, p, threshold) {
                count += 1
            }
            if isDarker(circleBottom, p, threshold) {
                count += 1
            }
            if isDarker(circleLeft, p, threshold) {
                count += 1
            }
            if count < 3 {
                return true
            }
        }
        
        return false
    }
    
    /**
     * Checks if the circle pixel is brighter than the candidate pixel p by
     * a threshold.
     */
    func isBrighter(_ circlePixel :Int, _ p :Int, _ threshold :Int)->Bool {
        return circlePixel-p > threshold
    }
    
    /**
     * Checks if the circle pixel is darker than the candidate pixel p by
     * a threshold.
     */
    func isDarker(_ circlePixel :Int, _ p :Int, _ threshold :Int) ->Bool {
        return p-circlePixel > threshold
    }
    
    /**
     * Gets the sixteen offset values of the circle surrounding pixel.
     */
    func getCircleOffsets(_ width:Int) -> [Int] {
        var circle:[Int] = []
        circle[0] = -width - width - width
        circle[1] = circle[0] + 1
        circle[2] = circle[1] + width + 1
        circle[3] = circle[2] + width + 1
        circle[4] = circle[3] + width
        circle[5] = circle[4] + width
        circle[6] = circle[5] + width - 1
        circle[7] = circle[6] + width - 1
        circle[8] = circle[7] - 1
        circle[9] = circle[8] - 1
        circle[10] = circle[9] - width - 1
        circle[11] = circle[10] - width - 1
        circle[12] = circle[11] - width
        circle[13] = circle[12] - width
        circle[14] = circle[13] - width + 1
        circle[15] = circle[14] - width + 1
        
        return circle
    }
}

