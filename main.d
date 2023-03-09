import std.algorithm;
import std.array;
import std.file;
import std.format;
import std.math;
import std.random;
import std.range;
import std.stdio;
import std.typecons;

class Image
{
    string filename;
    int[][] pixels;

    this(string filename)
    {
        this.filename = filename;
        this.pixels = loadPixels(filename);
    }

    int[][] loadPixels(string filename)
    {
        auto image = loadImage(filename);
        int[][] pixels = new int[][](image.height, image.width);

        foreach (i, row; pixels)
        {
            foreach (j, _; row)
            {
                pixels[i][j] = image.getPixel(j, i);
            }
        }

        return pixels;
    }

    void save(string filename)
    {
        auto image = new Bitmap(pixels[0].length, pixels.length);
        foreach (i, row; pixels)
        {
            foreach (j, pixel; row)
            {
                image.setPixel(j, i, pixel);
            }
        }

        image.save(filename);
    }
}

class BrickSet
{
    Image[] bricks;

    this(string directory)
    {
        auto files = dirEntries(directory, SpanMode.breadth);
        auto imageFiles = files.filter!(f => f.isFile && f.name.extension == ".jpg" || f.name.extension == ".png");
        this.bricks = imageFiles.map!(f => new Image(f.name)).array;
    }

    Image getRandomBrick()
    {
        int index = uniform(0, bricks.length - 1);
        return bricks[index];
    }
}

int getPixelAverage(Image image, int x, int y, int width, int height)
{
    int[] values;
    foreach (i, row; image.pixels[y..(y+height)])
    {
        foreach (j, pixel; row[x..(x+width)])
        {
            values ~= pixel;
        }
    }

    return values.reduce!((a, b) => a + b) / values.length;
}

Image createMosaic(Image image, BrickSet brickSet, int blockSize)
{
    auto newPixels = new int[][](image.pixels.length, image.pixels[0].length);

    foreach (i, row; newPixels)
    {
        foreach (j, _; row)
        {
            int average = getPixelAverage(image, j * blockSize, i * blockSize, blockSize, blockSize);
            Image brick = brickSet.getRandomBrick();
            int[][] brickPixels = brick.pixels;
            int height = brickPixels.length;
            int width = brickPixels[0].length;

            int closestDistance = int.max;
            int closestPixel = 0

        foreach (k, row2; brickPixels)
        {
            foreach (l, pixel; row2)
            {
                int distance = abs(pixel - average);

                if (distance < closestDistance)
                {
                    closestDistance = distance;
                    closestPixel = pixel;
                }
            }
        }

        foreach (k, row2; brickPixels)
        {
            foreach (l, pixel; row2)
            {
                int newPixel = closestPixel;
                int x = j * blockSize + l;
                int y = i * blockSize + k;
                newPixels[y][x] = newPixel;
            }
        }
    }
}

auto newImage = new Image("");
newImage.pixels = newPixels;
return newImage;

scss
Copy code
        foreach (k, row2; brickPixels)
        {
            foreach (l, pixel; row2)
            {
                int distance = abs(pixel - average);

                if (distance < closestDistance)
                {
                    closestDistance = distance;
                    closestPixel = pixel;
                }
            }
        }

        // Substituir o bloco na imagem original pelo tijolo mais próximo
        foreach (k, row2; brickPixels)
        {
            foreach (l, pixel; row2)
            {
                int newPixel = closestPixel;
                int x = j * blockSize + l;
                int y = i * blockSize + k;
                newPixels[y][x] = newPixel;
            }
        }
    }

{
auto newImage = new Image("");
newImage.pixels = newPixels;
return newImage;
}

void main(string[] args)
{
if (args.length != 3)
{
writeln("Usage: mosaic input_image output_image bricks_dir");
return;
}
auto inputImage = new Image(args[1]);
auto outputImage = createMosaic(inputImage, new BrickSet(args[3]), 50);
outputImage.save(args[2]);
}