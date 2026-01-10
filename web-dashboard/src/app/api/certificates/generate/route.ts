import { NextRequest, NextResponse } from 'next/server';
import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';
import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client
const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export async function GET(request: NextRequest) {
    try {
        const searchParams = request.nextUrl.searchParams;
        const name = searchParams.get('name') || 'Student Name';
        const eventName = searchParams.get('event') || 'Event Name';
        const date = searchParams.get('date') || new Date().toLocaleDateString();

        // Create a new PDF document
        const pdfDoc = await PDFDocument.create();

        // Add a landscape page (A4 landscape)
        const page = pdfDoc.addPage([842, 595]);
        const { width, height } = page.getSize();

        // Load fonts
        const helveticaFont = await pdfDoc.embedFont(StandardFonts.Helvetica);
        const helveticaBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);

        // Draw ornate border (simple gold rectangle for now)
        page.drawRectangle({
            x: 20,
            y: 20,
            width: width - 40,
            height: height - 40,
            borderColor: rgb(0.8, 0.6, 0.2), // Gold-ish
            borderWidth: 5,
        });

        // Header
        page.drawText('Certificate of Participation', {
            x: width / 2 - 200,
            y: height - 100,
            size: 32,
            font: helveticaBold,
            color: rgb(0, 0, 0),
        });

        // Body text
        const text1 = 'This is to certify that';
        const text2 = 'has successfully participated in';

        page.drawText(text1, {
            x: width / 2 - 80,
            y: height - 180,
            size: 18,
            font: helveticaFont,
        });

        // Student Name (Dynamic)
        const nameWidth = helveticaBold.widthOfTextAtSize(name, 48);
        page.drawText(name, {
            x: (width - nameWidth) / 2,
            y: height - 240,
            size: 48,
            font: helveticaBold,
            color: rgb(0.2, 0.4, 0.8), // Blue
        });

        page.drawText(text2, {
            x: width / 2 - 120,
            y: height - 300,
            size: 18,
            font: helveticaFont,
        });

        // Event Name (Dynamic)
        const eventWidth = helveticaBold.widthOfTextAtSize(eventName, 30);
        page.drawText(eventName, {
            x: (width - eventWidth) / 2,
            y: height - 340,
            size: 30,
            font: helveticaBold,
        });

        // Date
        page.drawText(`Date: ${date}`, {
            x: width / 2 - 60,
            y: height - 420,
            size: 14,
            font: helveticaFont,
            color: rgb(0.4, 0.4, 0.4),
        });

        // Footer / Logo Placeholder
        page.drawText('Organized by Sambhram College', {
            x: width / 2 - 100,
            y: 60,
            size: 12,
            font: helveticaFont,
            color: rgb(0.5, 0.5, 0.5),
        });

        // Serialize the PDFDocument to bytes (a Uint8Array)
        const pdfBytes = await pdfDoc.save();

        // Return the response
        return new NextResponse(pdfBytes, {
            headers: {
                'Content-Type': 'application/pdf',
                'Content-Disposition': `inline; filename="certificate.pdf"`,
            },
        });

    } catch (error) {
        console.error('Certificate generation error:', error);
        return NextResponse.json(
            { error: 'Failed to generate certificate' },
            { status: 500 }
        );
    }
}
