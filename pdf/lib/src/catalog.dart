/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of pdf;

/// Pdf Catalog object
class PdfCatalog extends PdfObject {
  /// This constructs a Pdf Catalog object
  PdfCatalog(
    PdfDocument pdfDocument,
    this.pdfPageList,
    this.pageMode,
    this.names,
  )   : assert(pdfPageList != null),
        assert(pageMode != null),
        assert(names != null),
        super(pdfDocument, '/Catalog');

  /// The pages of the document
  final PdfPageList pdfPageList;

  /// The outlines of the document
  PdfOutline outlines;

  /// The initial page mode
  final PdfPageMode pageMode;

  /// The initial page mode
  final PdfNames names;

  @override
  void _prepare() {
    super._prepare();

    /// the PDF specification version, overrides the header version starting from 1.4
    params['/Version'] = PdfName('/${pdfDocument.version}');

    params['/Pages'] = pdfPageList.ref();

    // the Outlines object
    if (outlines != null && outlines.outlines.isNotEmpty) {
      params['/Outlines'] = outlines.ref();
    }

    // the Names object
    params['/Names'] = names.ref();

    // the /PageMode setting
    params['/PageMode'] = PdfName(PdfDocument._PdfPageModes[pageMode.index]);

    if (pdfDocument.sign != null) {
      params['/Perms'] = PdfDict(<String, PdfDataType>{
        '/DocMDP': pdfDocument.sign.ref(),
      });
    }

    final widgets = <PdfAnnot>[];
    for (var page in pdfDocument.pdfPageList.pages) {
      for (var annot in page.annotations) {
        if (annot.annot.subtype == '/Widget') {
          widgets.add(annot);
        }
      }
    }

    if (widgets.isNotEmpty) {
      params['/AcroForm'] = PdfDict(<String, PdfDataType>{
        '/SigFlags': PdfNum(pdfDocument.sign?.flagsValue ?? 0),
        '/Fields': PdfArray.fromObjects(widgets),
      });
    }
  }
}
