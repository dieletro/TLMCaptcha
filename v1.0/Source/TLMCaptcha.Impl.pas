unit TLMCaptcha.Impl;
// Fonte:
//https://github.com/J-Rios/multicolor_captcha_generator/blob/master/img_captcha_gen.py
interface

{$REGION 'DOCUMENTAÇÃO'}
{
Criando máscaras de transparência

Podemos criar um sistema misto de transferência de imagens, onde uma máscara
previamente montada é usada para “limpar” antes a área que receberá a imagem com
transparência. Este sistema é particularmente útil em cópias de áreas restritas,
onde a transparência da imagem não é respeitada pelas funções de transferência.
Nas primeiras versões do Delphi era necessário criar essa máscara com um editor
gráfico e salvá-la junto com as imagens normais.

Podemos, no entanto, criar essas máscaras a partir do uso de cópias integrais
das imagens:

  //Copia a imagem original em Bmp2
  Bmp2.Assign(Bmp1);
  //Transforma a cópia numa imagem P&B
  Bmp2.Mask(clFuchsia);
  //Muda o parâmetro de cópia
  Bmp2.Canvas.CopyMode:= cmDSTINVERT;
  //Inverte a máscara
  Bmp2.Canvas.Draw(0,0,Bmp2);
  Bmp1.Canvas.CopyMode:= cmSRCAND;
  //”Limpa” a área transparente da imagem original
  Bmp1.Canvas.Draw(0,0,Bmp2);
  //Inverte novamente a máscara
  Bmp2.Canvas.Draw(0,0,Bmp2);
  //Repõe os parâmetros default
  Bmp2.Canvas.CopyMode:= cmSRCCOPY;
  Bmp1.Canvas.CopyMode:= cmSRCCOPY;

Usando Bitblt

Bitblt é uma função da API gráfica (GDI) do Windows. Para ser usada requer um handle, ou seja, um apontador específico para a área gráfica (o Canvas). Um Hbitmap.

var
  Htela: Hbitmap;
begin
  Htela:= Img1.Canvas.Handle;
  ...
A partir daqui, usamos Htela para referenciar a área gráfica da nossa imagem (Img1).

  ...
  BitBlt(HTela,0,0,100,50,HTela,200,250,SRCCOPY);
Copiar o pedaço, cujo canto superior esquerdo da imagem Htela está em 200,250 e que tem o tamanho 100 pixels de largura por 50 pixels de altura, na imagem Htela (a mesma portanto), a partir do canto superior esquerdo 0,0. Pode-se também copiar a tela toda, com esse método.

Usamos o bitblt não tanto por ser mais rápido que as funções normais, relacionadas com TImage e TBimap, mas porque é mais intuitivo que o CopyRect.


4- Os mais importantes parâmetros de transferência

Tanto bitblt como canvas.copyrect possuem parâmetros de cópia, ou seja, valores que influem na forma como o Windows irá copiar uma imagem para outro local. Os principais são:

Blackness
Preenche o retângulo destino com a cor preta;

DstInvert
Inverte as cores da imagem, na área destino;

SrcAnd
Combina a imagem origem com a imagem destino, usando a operação boleana AND;

SrcCopy
Copia o retângulo origem, no retângulo destino;

SrcErase
Inverte as cores da imagem origem e combina o resultado com a área destino usando a operação boleana AND;

SrcInvert
Combina a imagem origem e a imagem destino usando a operação boleana XOR;

SrcPaint
Combina a imagem origem e a imagem destino usando a operação boleana OR;

Whiteness
Preenche o retângulo destino com a cor preta;

}
{$ENDREGION 'DOCUMENTAÇÃO'}

Uses

  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Dialogs,

  System.Types, Winapi.Windows, Math,
  System.SysUtils ,System.Classes,
  System.Generics.Collections,
  TLMCaptcha.Base;


type
  //Definição dos Tipos de Caracteres
  TCharSet_modes = (cmASCII_UPPER = 0, cmASCII_LOWER = 1, cmHEX = 2, cmNUM = 3,  cmALL = 4);

  //Definição do array de 2 posições do tipo inteiro
  TRangeSize = array[0..1] of Integer;

  //Record usado para conversões de TColor para RGB
  TRGB = record
    R: byte;
    G: byte;
    B: byte;
  end;

  //Definição de um Tipo para o retorno do Captcha
{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  TRecGenerated_captcha
    ///  Use this type to get the captcha character and captcha image.
    /// </summary>
    /// <param name="image" type="TImage">
    /// TImage Object
    /// </param>
    /// <param name="character" type="String">
    /// String of the character
    /// </param>
    /// <returns>
    /// On success, return TRecGenerated_captcha.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
  TRecGenerated_captcha = record
      image : Timage;
      character: String;
  end;

const
// Os tamanhos de fonte variam para cada Intervalo
AFONT_SIZE_RANGE : Array[0..12] of TRangeSize = ((20, 45),(35, 80), (75, 125),
                   (80, 140), (85, 150),(90, 165),(100, 175),(110, 185), (125, 195),
                   (135, 210), (150, 230),(165, 250), (180, 290));

// Captcha 16:9 resolution sizes (captcha_size_num -> 0 to 12)
ACAPTCHA_SIZE : Array[0..12] of TRangeSize = ((256, 144), (426, 240), (640, 360), (768, 432), (800, 450), (848, 480),
                (960, 540), (1024, 576), (1152, 648), (1280, 720), (1366, 768), (1600, 900),
                (1920, 1080));

{Níveis difíceis capturam os valores de geração (<linhas no total img>,
<círculos no total img>)}
ADIFFICULT_LEVELS_VALUES : Array[0..4] of TRangeSize = (
                  (1, 8), (2, 10), (3, 15), (4, 25), (5, 30));

{Niveis de dificuldade para as Distorções da imagem, eles correspondem a
quantidade de Pixel alpicado nas distorções de cada nivel}
ADISTORCAO_LEVELS_VALUES : Array[0..4] of TRangeSize = (
                  (2000, 4000),(4000, 6000),(6000, 8000),(8000, 10000),(10000, 12000));

//Lista de Fontes Aceitas
AFONT_TYPE_RANGE: array [0..9] of string = (
                'Courier New', 'Impact', 'Times New Roman',
                'Verdana', 'Arial', 'Colonna MT', 'Calibri, ',
                'ALGERIAN', 'Bauhaus 93', 'Cooper Black' );

//Lista de Caracteres HEX Aceitos
AAvaliableHEX = 'ABCDEF0123456789';

//Lista de Caracteres ASCII, com letras Minúsculas, Aceitas
AAvaliableASCII_LOWER = 'abcdefghijklmnopqrstuvwxyz';

//Lista de Caracteres ASCII, com letras Maiúsculas, Aceitas
AAvaliableASCII_UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

//Lista de Caracteres ASCII com todas as letras e numeros Aceitos
AAvaliableASCII_UPPER_and_LOWER =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'+
        '0123456789' +
        'abcdefghijklmnopqrstuvwxyz';

type
  TCaptchaGenerator = class(TLMCaptchaAbstractComponent)
  private
    FCaptcha_size: TRangeSize;
    FDiv_size: Extended;
    FFont_size_range: TRangeSize;
    FOne_char_image_size: TSize;
    FFont_size_max: Integer;
    FFont_size_min: Integer;
    FCaptcha: TImage;
    FTamanhoCaptcha: Integer;
    FAltura: Integer;
    FLargura: Integer;
    FNumeroDeCaracteres: Integer;
    FCharSetMODE: TCharSet_modes;
    FDistorcao: Boolean;
    FMultiCores: Boolean;
    FNivelDificuldade: Integer;
    FUsarMargens: Boolean;
    FAoCriar: TNotifyEvent;
    FAoDestruir: TNotifyEvent;
    FAoGerar: TNotifyEvent;
    FAoJuntarImagens: TNotifyEvent;
    FAoAdicionarEfeito: TNotifyEvent;
    FAnguloDistCaracter: Integer;
    FLarguraBorda: Integer;
    procedure SetCaptcha(const Value: TImage);
    procedure SetTamanhoCaptcha(const Value: Integer);
    procedure SetCharSetMODE(const Value: TCharSet_modes);
  public
{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  Create
    ///  Use this method to create the captcha object.
    /// </summary>
    /// <param name="AOwner" type="TComponent">
    /// Object type of the TComponent
    /// </param>
    /// <returns>
    /// Constructor Method.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    constructor Create(AOwner: TComponent); override;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  Destroy
    ///  Use this method to destroy the captcha object.
    /// </summary>
    /// <returns>
    /// Destructor Method.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    destructor Destroy; override;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  Inicializar
    ///  Use this method to Init the param and var.
    /// </summary>
    /// <returns>
    /// Init Method.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    procedure Inicializar;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  ComoRGB
    ///  Use this method to convert the TColor type to RGB Color.
    /// </summary>
    /// <param name="AForm_Color" type="TColor">
    /// TColor for conversion
    /// </param>
    /// <returns>
    /// RGB color type.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function ComoRGB(AForm_Color: TColor): TRGB;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    /// cor_escura
    /// Use this function to get medium tonality for RGB in 0-255 range
    /// -> (255/2)*3 = 384.
    /// </summary>
    /// <param name="R" type="Byte">
    /// Red Color
    /// </param>
    /// <param name="G" type="Byte">
    /// Green Color
    /// </param>
    /// <param name="B" type="Byte">
    /// Blue Color
    /// </param>
    /// <returns>
    /// On success, return True.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function cor_escura(R,G,B : Byte): Boolean;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    /// nivel_contraste_da_cor
    /// Use this function to get a level of color based on the byte of
    /// the primary bases of the colors in the RGB standard
    /// Set the level of dark tint of the color provided from -3 to 3
    /// -3 ultra light,
    /// -2 medium light,
    /// -1 low light,
    /// 1 low darkness,
    /// 2 medium darkness,
    /// 3 high darkness.
    /// </summary>
    /// <param name="R" type="Byte">
    /// Red Color
    /// </param>
    /// <param name="G" type="Byte">
    /// Green Color
    /// </param>
    /// <param name="B" type="Byte">
    /// Blue Color
    /// </param>
    /// <returns>
    /// On success, return a level value in Integer type.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function nivel_contraste_da_cor(R,G,B : Byte): Integer;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    /// gerar_cor_rand
    /// Use this function to generate a random color based on the byte range of
    /// the primary bases of the colors in the RGB standard
    /// </summary>
    /// <param name="min_val" type="Integer">
    /// min byte value to generate RGB colors, default is 0.
    /// </param>
    /// <param name="max_val" type="Integer">
    /// max byte value to generate RGB colors, default is 255.
    /// </param>
    /// <returns>
    /// On success, return TColor.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function gerar_cor_rand(const min_val: Integer = 0; max_val: Integer = 255): TColor;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    /// gerar_cor_contraste_custom
    /// Use this function to generate a random custom contrast color from a specific color
    /// </summary>
    /// <param name="from_color" type="TColor">
    /// Base color to generate contrast colors
    /// </param>
    /// <returns>
    /// On success, return TColor.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function gerar_cor_contraste_custom(from_color: TColor): TColor;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    /// gerar_cor_contraste_rand
    /// Use this function to generate a random contrast color from a specific color
    /// </summary>
    /// <param name="from_color" type="TColor">
    /// Base color to generate contrast colors
    /// </param>
    /// <returns>
    /// On success, return TColor.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function gerar_cor_contraste_rand(from_color: TColor): TColor;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    /// gerar_fonte_rand
    /// Use this function to define a font name in the list of strings,
    /// a name available in the list of valid font names.
    /// </summary>
    /// <param name="fonts_list" type="array of string">
    /// Font list Names, type array of string
    /// </param>
    /// <returns>
    /// On success, return font name in the String.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function gerar_fonte_rand(fonts_list: array of string): String;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  gerar_tamanho_rand_fonte
    ///  Use this function to generate Tfont Type for character.
    /// </summary>
    /// <param name="font_nome" type="String">
    /// Font Name String type
    /// </param>
    /// <param name="min_size" type="Integer">
    /// min size for font
    /// </param>
    /// <param name="max_size" type="Integer">
    /// max size for font
    /// </param>
    /// <returns>
    /// On success, return TFont.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function gerar_tamanho_rand_fonte(font_nome: String; min_size,
      max_size: Integer): TFont;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  inverter_caracter_imagem
    ///  Use this method to inverter character on the image.
    /// </summary>
    /// <param name="image" type="TImage">
    /// var image of type TImage Object
    /// </param>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    procedure inverter_caracter_imagem(var image : TImage);

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  add_circulo_rand_na_imagem
    ///  Use this method to add circle random on the captcha.
    /// </summary>
    /// <param name="image" type="TImage">
    /// var image of type TImage Object
    /// </param>
    /// <param name="min_size" type="Integer">
    /// min size
    /// </param>
    /// <param name="max_size" type="Integer">
    /// max size
    /// </param>
    /// <param name="circle_color" type="TColor">
    /// circle color, default is clNone
    /// </param>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    procedure add_circulo_rand_na_imagem(var image : TImage;
        const min_size, max_size : Integer; circle_color: TColor = clNone);

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  add_elipse_rand_na_imagem
    ///  Use this method to add ellipse random on the captcha.
    /// </summary>
    /// <param name="image" type="TImage">
    /// var image of type TImage Object
    /// </param>
    /// <param name="w_min" type="Integer">
    /// width min
    /// </param>
    /// <param name="w_max" type="Integer">
    /// width max
    /// </param>
    /// <param name="h_min" type="Integer">
    /// height min
    /// </param>
    /// <param name="h_max" type="Integer">
    /// height max
    /// </param>
    /// <param name="ellipse_color" type="TColor">
    /// ellipse color, default is clNone
    /// </param>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    procedure add_elipse_rand_na_imagem(var image: Timage;
        const w_min, w_max, h_min, h_max: Integer; ellipse_color: TColor = clNone);

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  add_traco_rand_na_imagem
    ///  Use this method to add lines random on the captcha.
    /// </summary>
    /// <param name="image" type="TImage">
    /// var image of type TImage Object
    /// </param>
    /// <param name="line_width" type="Integer">
    /// line width, default is 5
    /// </param>
    /// <param name="line_color" type="TColor">
    /// line color, default is clNone
    /// </param>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    procedure add_traco_rand_na_imagem(var  image: TImage;
        const line_width: Integer = 5; line_color: TColor = clNone);

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  add_quadrados_rand_na_imagem
    ///  Use this method to add square forms random on the captcha.
    /// </summary>
    /// <param name="image" type="TImage">
    /// var image of type TImage Object
    /// </param>
    /// <param name="min_size" type="Integer">
    /// min size for square
    /// </param>
    /// <param name="max_size" type="Integer">
    /// max size for square
    /// </param>
    /// </param>
    /// <param name="quadrado_cor" type="TColor">
    /// Color for brush the square, default is clNone
    /// </param>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    procedure add_quadrados_rand_na_imagem(var image : TImage;
        const min_size, max_size : Integer; quadrado_cor: TColor = clNone);

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  add_linha_horizontal_rand_na_imagem
    ///  Use this method to add horizontal lines random on the captcha.
    /// </summary>
    /// <param name="image" type="TImage">
    /// var image of type TImage Object
    /// </param>
    /// <param name="line_width" type="Integer">
    /// line width, default is 5
    /// </param>
    /// <param name="line_color" type="TColor">
    /// line color, default is clNone
    /// </param>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    procedure add_linha_rand_na_imagem(var  image: TImage;
        const line_width: Integer = 5; line_color: TColor = clNone);

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  add_linha_horizontal_rand_na_imagem
    ///  Use this method to add horizontal lines random on the captcha.
    /// </summary>
    /// <param name="image" type="TImage">
    /// var image of type TImage Object
    /// </param>
    /// <param name="line_width" type="Integer">
    /// line width, default is 5
    /// </param>
    /// <param name="line_color" type="TColor">
    /// line color, default is clNone
    /// </param>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    procedure add_linha_horizontal_rand_na_imagem(var image: TImage;
        const line_width: Integer = 5; line_color: TColor = clNone);

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  add_distorcao_rand_na_imagem
    ///  Use this method to add distorcion pixel on the captcha.
    /// </summary>
    /// <param name="image" type="TImage">
    /// var image of type TImage Object
    /// </param>
    /// <param name="num_pixels" type="Integer">
    /// Number of the pixel distorcion in the captcha
    /// </param>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    procedure add_distorcao_rand_na_imagem(var  image: TImage; num_pixels: Integer);

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  juntar_imagens_na_horizontal
    ///  Use this method to join images on horizontal.
    /// </summary>
    /// <param name="image" type="TImage">
    /// TImage Object
    /// </param>
    /// <param name="list_images" type="TObjectList<TImage>">
    /// Array List of the images TObjectList<TImage>
    /// </param>
    /// <returns>
    /// On success, return TImage.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function juntar_imagens_na_horizontal(var image: TImage; list_images: TObjectList<TImage>): TImage;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  Criar_imagem_do_caracter
    ///  Use this method to create a image of the character.
    /// </summary>
    /// <param name="size" type="TSize">
    /// dimenssion of the imageof the character
    /// </param>
    /// <param name="background" type="TColor">
    /// define the background color for this background image character
    /// </param>
    /// <param name="character" type="String">
    /// define the character string for this image caracter
    /// </param>
    /// <param name="char_color" type="TColor">
    /// define the character color
    /// </param>
    /// <param name="char_pos" type="TSize">
    /// define the character position
    /// </param>
    /// <param name="char_font" type="TFont">
    /// define the character TFont Object
    /// </param>
    /// <returns>
    /// On success, return TImage.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function Criar_imagem_do_caracter(size: TSize; background: TColor;
        character: String; char_color: TColor; char_pos: TSize; char_font: TFont) : TImage;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  Gerar_imagem_do_caracter_captcha
    ///  Use this method to generate caracter image Captcha.
    /// </summary>
    /// <param name="image_size" type="TSize">
    /// dimenssion of the image
    /// </param>
    /// <param name="background_color" type="TColor">
    /// define the background color for image captcha
    /// </param>
    /// <returns>
    /// On success, return TRecGenerated_captcha.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function Gerar_imagem_do_caracter_captcha(image_size: TSize;
        background_color: TColor = clNone): TRecGenerated_captcha;

{$REGION 'DOCUMENTAÇÃO'}
    /// <summary>
    ///  Gerar_imagem_captcha
    ///  Use this method to generate the Captcha.
    /// </summary>
    /// <param name="image" type="TImage">
    /// TImage Object
    /// </param>
    /// <param name="difficult_level" type="Integer">
    /// difficult level for generation captcha
    /// </param>
    /// <param name="multicolor" type="Boolean">
    /// Use true for multicolor is enabled in generation this captcha
    /// </param>
    /// <param name="margin" type="Boolean">
    /// Use true for margin is enabled in generation this captcha
    /// </param>
    /// <returns>
    /// On success, return TRecGenerated_captcha.
    /// </returns>
    /// <seealso href="" />
{$ENDREGION 'DOCUMENTAÇÃO'}
    function Gerar_imagem_captcha(var  image: TImage; difficult_level: Integer = 2;
        multicolor: Boolean = False; margin: Boolean = True): TRecGenerated_captcha;

    property captcha_size: TRangeSize read FCaptcha_size write FCaptcha_size;
    property font_size_range: TRangeSize read FFont_size_range write FFont_size_range;
    property one_char_image_size: TSize read FOne_char_image_size write FOne_char_image_size;
  published
    {Eventos}
    property AoCriar: TNotifyEvent read FAoCriar write FAoCriar;
    property AoDestruir: TNotifyEvent read FAoDestruir write FAoDestruir;
    property AoGerar: TNotifyEvent read FAoGerar write FAoGerar;
    property AoJuntarImagens: TNotifyEvent read FAoJuntarImagens write FAoJuntarImagens;
    property AoAdicionarEfeito: TNotifyEvent read FAoAdicionarEfeito write FAoAdicionarEfeito;

    {Propriedades}
    property DivSize: Extended read FDiv_size write FDiv_size;
    property FontSizeMin: Integer read FFont_size_min write FFont_size_min;
    property FontSizeMax: Integer read FFont_size_max write FFont_size_max;
    property Captcha : TImage read FCaptcha write SetCaptcha;

    property TamanhoCaptcha: Integer read FTamanhoCaptcha write SetTamanhoCaptcha default 2;
    property Altura: Integer read FAltura;
    property Largura: Integer read FLargura;
    property NumeroDeCaracteres: Integer read FNumeroDeCaracteres write FNumeroDeCaracteres default 4;
    property CharSetMODE: TCharSet_modes read FCharSetMODE write SetCharSetMODE default cmASCII_UPPER;
    property Distorcao: Boolean read FDistorcao write FDistorcao default True;
    Property MultiCores: Boolean read FMultiCores write FMultiCores default True;
    property NivelDificuldade: Integer read FNivelDificuldade write FNivelDificuldade default 2;
    property UsarMargens: Boolean read FUsarMargens write FUsarMargens default false;
    property AnguloDistCaracter: Integer read FAnguloDistCaracter write FAnguloDistCaracter default 30;
    property LarguraBorda: Integer read FLarguraBorda write FLarguraBorda default 2;
  end;

implementation

{ TCaptchaGenerator }

procedure TCaptchaGenerator.add_circulo_rand_na_imagem(var image: TImage; const min_size,
  max_size: Integer; circle_color: TColor);
var
  x, y, rad: Integer;
begin

  x   := RandomRange(0, captcha_size[0]);
  y   := RandomRange(0, captcha_size[1]);
  rad := RandomRange(min_size, max_size);

  if circle_color = clNone then
      circle_color := RGB(
          RandomRange(0, 255), //R
          RandomRange(0, 255), //G
          RandomRange(0, 255));//B

  with image.Picture.Bitmap do
  Begin
    Canvas.Brush.Color := circle_color;
    Canvas.Pen.Color := circle_color;
    Canvas.Ellipse(x, y, x+rad, y+rad);
  End;

  if Assigned(AoAdicionarEfeito) then
    AoAdicionarEfeito(Self);
end;

procedure TCaptchaGenerator.add_elipse_rand_na_imagem(var image: Timage; const w_min, w_max, h_min,
  h_max: Integer; ellipse_color: TColor);
var
  x, y, w, h: Integer;
begin

  x := RandomRange(0, captcha_size[0]);
  y := RandomRange(0, captcha_size[1]);
  w := RandomRange(w_min, w_max);
  h := RandomRange(h_min, h_max);

  if ellipse_color = clNone then
      ellipse_color := RGB(
            RandomRange(0, 255), //R
            RandomRange(0, 255), //G
            RandomRange(0, 255));//B

  with image.Picture.Bitmap do
  Begin
    Canvas.Brush.Color := ellipse_color;
    Canvas.Pen.Color := ellipse_color;
    Canvas.Ellipse(x, y, x+w, y+h);
  End;

  if Assigned(AoAdicionarEfeito) then
    AoAdicionarEfeito(Self);
end;

procedure TCaptchaGenerator.add_linha_horizontal_rand_na_imagem(var image: TImage;
  const line_width: Integer; line_color: TColor);
var
  x0, x1, y0, y1: Integer;
begin
{$REGION 'DOCUMENTAÇÃO'}

  { Obter posição inicial aleatória da linha (
    x entre 0 e 20% da largura da imagem;
    y com faixa de altura total}
  x0 := RandomRange(0, Round(0.2 * captcha_size[0]));
  y0 := RandomRange(0, captcha_size[1]);

  {Obter posição final da linha
    x1 simétrico a x0;
    y aleatório de y0 à altura da imagem}
  x1 := captcha_size[0] - x0;
  y1 := RandomRange(y0, captcha_size[1]);

  // Gere uma cor de linha aleatória se não for fornecida
  if line_color = clNone then
      line_color := RGB(
              RandomRange(0, 255), //R
              RandomRange(0, 255), //G
              RandomRange(0, 255));//B

  // Obter interface de desenho de imagem e desenhar a linha nele
  with image.Picture.Bitmap do
  Begin
    Canvas.Pen.Color := line_color;
    Canvas.Pen.Width := line_width;
    Canvas.LineTo(x0, y0);
    Canvas.MoveTo(x0 + x0,y0 + y0);
    Canvas.LineTo(x1, y1);
    Canvas.MoveTo(x1 + x1,y1 + y1);
  End;

  if Assigned(AoAdicionarEfeito) then
    AoAdicionarEfeito(Self);

end;

procedure TCaptchaGenerator.add_linha_rand_na_imagem(var image: TImage; const line_width: Integer;
  line_color: TColor);
var
  line_x0, line_x1, line_y0, line_y1: Integer;
begin

// Get line random start position
line_x0 := RandomRange(0, captcha_size[0]);
line_y0 := RandomRange(0, captcha_size[1]);
// If line x0 is in center-to-right
if line_x0 >= (captcha_size[0] div 2)then
    // Line x1 from 0 to line_x0 position - 20% of image width
    line_x1 := RandomRange(0, (line_x0 - (0.2*captcha_size[0])).Size)
else
    // Line x1 from line_x0 position + 20% of image width to max image width
    line_x1 := RandomRange((line_x0 + (0.2*captcha_size[0]).Size), captcha_size[0]);
// If line y0 is in center-to-bottom
if line_y0 >= (captcha_size[1] div 2) then
    // Line y1 from 0 to line_y0 position - 20% of image height
    line_y1 := RandomRange(0, (line_y0 - (0.2*captcha_size[1]).Size))
else
    // Line y1 from line_y0 position + 20% of image height to max image height
    line_y1 := RandomRange((line_y0 + (0.2*captcha_size[1]).Size), captcha_size[1]);
// Generate a rand line color if not provided
if line_color = clNone then
    line_color := RGB(
                  RandomRange(0, 255), //R
                  RandomRange(0, 255), //G
                  RandomRange(0, 255));//B

// Get image draw interface and draw the line on it
  with image.Picture.Bitmap do
  Begin
    Canvas.Pen.Color := line_color;
    Canvas.Pen.Width := line_width;
    Canvas.LineTo(line_x0, line_y0);
    Canvas.MoveTo(line_x0 + line_x0, line_y0 + line_y0);
    Canvas.LineTo(line_x1, line_y1);
    Canvas.MoveTo(line_x1 + line_x1, line_y1 + line_y1);
  End;

  if Assigned(AoAdicionarEfeito) then
    AoAdicionarEfeito(Self);

end;

procedure TCaptchaGenerator.add_quadrados_rand_na_imagem(var image : TImage;
      const min_size, max_size : Integer; quadrado_cor: TColor = clNone);
var
  x, y, quad : Integer;
begin

  x   := RandomRange(0, captcha_size[0]);
  y   := RandomRange(0, captcha_size[1]);
  quad := RandomRange(min_size, max_size);

  // Gere uma cor de linha aleatória se não for fornecida
  if quadrado_cor = clNone then
      quadrado_cor := RGB(
              RandomRange(0, 255), //R
              RandomRange(0, 255), //G
              RandomRange(0, 255));//B

  // Obter interface de desenho de imagem e desenhar a linha nele
  with image.Picture.Bitmap do
  Begin
    Canvas.Pen.Color := quadrado_cor;
    Canvas.Brush.Color := quadrado_cor;
    Canvas.Rectangle(x, y, x+quad, y+quad);
  End;

  if Assigned(AoAdicionarEfeito) then
    AoAdicionarEfeito(Self);

end;

procedure TCaptchaGenerator.add_traco_rand_na_imagem(var image: TImage;
  const line_width: Integer; line_color: TColor);
var
  x, y: Integer;
begin
  { Obter posição inicial aleatória da linha (
    x entre 0 e 20% da largura da imagem;
    y com faixa de altura total}
  x := Random(Round(0.2 * captcha_size[0]));
  y := RandomRange(0, captcha_size[1]);

  // Gere uma cor de linha aleatória se não for fornecida
  if line_color = clNone then
      line_color := RGB(
              RandomRange(0, 255), //R
              RandomRange(0, 255), //G
              RandomRange(0, 255));//B

  // Obter interface de desenho de imagem e desenhar a linha nele
  with image{.Picture.Bitmap} do
  Begin
    Canvas.Pen.Color := line_color;
    Canvas.Pen.Width := line_width;
    Canvas.LineTo(x, y);
    Canvas.MoveTo(x + x ,y + y);
  End;

  if Assigned(AoAdicionarEfeito) then
    AoAdicionarEfeito(Self);

end;

procedure TCaptchaGenerator.add_distorcao_rand_na_imagem(var image: TImage;
  num_pixels: Integer);
var
  pixel_color : TColor;
  I: Integer;
begin

  with image.Picture.Bitmap do
  Begin

    for I:= 0 to num_pixels do
    Begin

      pixel_color := gerar_cor_rand();

      Canvas.Pixels[
          RandomRange(0, captcha_size[0]){Round(0.2 * captcha_size[0]))}, //X
          RandomRange(0, captcha_size[1]) //Y
                   ] := pixel_color;
    End;

  End;

  if Assigned(AoAdicionarEfeito) then
    AoAdicionarEfeito(Self);

end;

function TCaptchaGenerator.nivel_contraste_da_cor(R, G, B: Byte): Integer;
Var
  dark_level: Integer;
begin
{Determine o nível de tonalidade escuro da cor fornecida de -3 a 3
(-3 ultra claro, \ -2 luz média, -1 luz fraca, 1 escuridão baixa,
 2 escuridão média, 3 escuridão alta).}
  dark_level := 0;
  if (r + g + b) < 384 then
  Begin
    dark_level := 1;
    if (r + g + b) < 255 then
        dark_level := 2;
    if (r + g + b) < 128 then
        dark_level := 3;
    result := 1;
  End
  else
    dark_level := -1;
  if (r + g + b) > 512 then
      dark_level := -2;
  if (r + g + b) > 640 then
      dark_level := -3;
  result := dark_level;
end;

function TCaptchaGenerator.cor_escura(r, g, b: Byte): Boolean;
begin

  // Tonalidade média para RGB no intervalo de 0 a 255 -> (255/2) * 3 = 384
  if (r + g + b) < 384 then
      result := True
  else
      result :=  False;

end;

constructor TCaptchaGenerator.Create(AOwner: TComponent);
begin
  FLarguraBorda := 2;
  FAnguloDistCaracter := 30;
  FTamanhoCaptcha := 2;
  FNumeroDeCaracteres := 4;
  FNivelDificuldade := 2;
  FCharSetMODE := cmASCII_UPPER;
  FMultiCores := True;
  FDistorcao := True;
  FUsarMargens := False;

  inherited Create(AOwner);

  Inicializar;

  if Assigned(AoCriar) then
    AoCriar(Self);

end;

function TCaptchaGenerator.Criar_imagem_do_caracter(size: TSize;
  background: TColor; character: String; char_color: TColor;
  char_pos: TSize; char_font: TFont) : TImage;
Var
  AImageDraw :TImage;
begin

  AImageDraw := Timage.Create(self);

  with AImageDraw.Picture.Bitmap do
  Begin
    Canvas.Brush.Color := background;
    Width  := size.Width;
    Height := size.Height;

    Canvas.Font := char_font;
    Canvas.Font.Orientation := (RandomRange(-(FAnguloDistCaracter), FAnguloDistCaracter) * 10);

    if  FUsarMargens then
    Begin
      Canvas.Pen.Width := FLarguraBorda;
      Canvas.Pen.Color := clBlack;
      Canvas.Rectangle(0,0, Width, Height);
    End;

    Canvas.Font.Color := char_color;

    { TODO 5 -oRuan Diego Lacerda Menezes -cCriar Caracter :
    Este metodo está em fase de reformulação, para um melhor resultado
    na geração de angulos diversos }

                   //Centro = -30
    if (Canvas.Font.Orientation > 100) then
      Canvas.TextOut(-30 + Round(0.46875 * char_pos.Width ),
          char_pos.Height + Round(0.3 * char_pos.Height ), character)
    else           //Centro = 100
    if (Canvas.Font.Orientation < -100) then
      Canvas.TextOut(100 + Round(0.15625 * char_pos.Width ),
           char_pos.Height - Round(0.46875 * char_pos.Height), character)
    else
      Canvas.TextOut(char_pos.Width, char_pos.Height, character);
  End;

  Result := AImageDraw;
end;

destructor TCaptchaGenerator.Destroy;
begin
  //
  inherited;

  if Assigned(AoDestruir) then
    AoDestruir(Self);
end;

function TCaptchaGenerator.Gerar_imagem_do_caracter_captcha(image_size: TSize;
  background_color: TColor): TRecGenerated_captcha;
var
  character,
  characters_availables,
  rand_font_path: String;
  rand_color, character_color : TColor;
  character_pos : TSize;
  character_font: TFont; //TEstando este tipo
  I: Integer;
  generated_captcha : TRecGenerated_captcha;
begin

// Definindo o modo de caracteres válidos a ser usado
case FCharSetMODE of

  cmNUM: Begin
    character := IntToStr(RandomRange(0, 9));
  End;

  cmASCII_UPPER: Begin
      characters_availables := AAvaliableASCII_UPPER;
      character := Copy(characters_availables, Random(length(characters_availables)), 1);
  End;

  cmASCII_LOWER: Begin
      characters_availables := AAvaliableASCII_LOWER;
      character := Copy(characters_availables, Random(length(characters_availables)), 1);
  End;

  cmHEX: Begin
      characters_availables := AAvaliableHEX;
      character := Copy(characters_availables, Random(length(characters_availables)), 1);
  End;

  cmALL : Begin
      characters_availables := AAvaliableASCII_UPPER_and_LOWER;
      character := Copy(characters_availables, Random(length(characters_availables)), 1);
  End;
end;

  // Se não for fornecida a cor de fundo, gere uma cor aleatória
  if background_color = clNone then
      background_color := gerar_cor_rand();

  //Definindo uma cor para a fonte com Auto Contraste em relação a cor do Fundo
  rand_color := gerar_cor_contraste_custom(background_color);

  //Definindo uma fonte aleatória na lista fornecida
  rand_font_path := gerar_fonte_rand(AFONT_TYPE_RANGE);

  //Definindo um Tamanho aleatório para a fonte selecionada
  character_font := gerar_tamanho_rand_fonte(rand_font_path, FFont_size_range[0], FFont_size_range[1]);

  //Atribuindo a Cor de auto Contraste na letra
  character_color := rand_color;

  //Define a posição na largura do Caracter CANTO = 0
  character_pos.Width  := RandomRange(0 ,(image_size.Width div FNumeroDeCaracteres) + 20);

  //Define a posição na autura do Caracter  // Topo = -10
  character_pos.Height := RandomRange(-10, (image_size.Height - 50) - character_font.Size);

  //Criando uma imagem com tamanho, cor de fundo e caráter, especificados
  FCaptcha := Criar_imagem_do_caracter(image_size, background_color,
      character, character_color, character_pos, character_font);

  // Adicione algumas linhas aleatórias à imagem
  for I := 0 to 2 do
      add_traco_rand_na_imagem(FCaptcha, 3, character_color);

  // Adicione pixels de ruído à imagem
  if FDistorcao = true then
      add_distorcao_rand_na_imagem(FCaptcha, RandomRange(
              ADISTORCAO_LEVELS_VALUES[FNivelDificuldade][0],
              ADISTORCAO_LEVELS_VALUES[FNivelDificuldade][1]));

  //Retornar a imagem gerada
  generated_captcha.image := TImage.Create(FCaptcha);
  generated_captcha.image := FCaptcha;
  generated_captcha.character := character;
  result := generated_captcha;

end;

function TCaptchaGenerator.Gerar_imagem_captcha(var image: TImage;
  difficult_level: Integer; multicolor, margin: Boolean): TRecGenerated_captcha;
var
//  new_image : TImage; //Em fase de reformulação
  image_background, efeitos_background: TColor;
  image_characters: String;
  AListaImagem_Um_Caract : TObjectList<TImage>;
  I: Integer;
  generated_captcha, captcha : TRecGenerated_captcha;
begin

  Inicializar;

  // Limite o argumento de nível difícil se estiver fora do intervalo esperado
  if FNivelDificuldade < 1 then
  Begin
    Showmessage('INFO: Geração de captcha para um nível de dificuldade mais baixo do que o esperado.'+
        sLineBreak+' Usando o nível 1 de dificuldade.');

    FNivelDificuldade := 1;
  End
  else
  if FNivelDificuldade > 5 then
  Begin
    Showmessage('INFO: Geração de captcha para um nível de dificuldade mais alto do que o esperado.'+
        sLineBreak+' Usando o nível 5 de dificuldade.');

    FNivelDificuldade := 5;
  End;

  // Defina o nível difícil para os valores do índice da matriz (1-5 a 0-4)
  FNivelDificuldade := FNivelDificuldade - 1;

  // Gere uma cor de fundo RGB se o multicolor estiver desativado
  if not FMultiCores then
      image_background := gerar_cor_rand();

  //Verificando a existencia do Objeto
  if Assigned(FCaptcha) then
  Begin

    // Gerando as imagens de um caractere com uma cor aleatória em contraste
    // com a gerada no fundo, uma fonte e tamanho de fonte aleatórios e rotação
    // de posição aleatória

    //Criando a Lista de Caracteres de Imagem
    AListaImagem_Um_Caract := TObjectList<TImage>.Create;

    with image.Picture.Bitmap do
    Begin
      //Defina as dimensões da imagem
      Width  :=  FCaptcha_size[0];
      Height :=  FCaptcha_size[1];

      //Inicialize a variavel que irá armazenar o caracter gerado
      image_characters := '';
      for I := 0 to FNumeroDeCaracteres - 1 do
      Begin
        // Gere uma cor de plano de fundo RGB para cada iteração se
        // multicolor estiver ativado
        if FMultiCores then
            image_background := gerar_cor_rand();

        // Gere um caractere aleatório, uma cor de caractere aleatório em
        // contraste com o fundo e uma posição aleatória para ele
        captcha := Gerar_imagem_do_caracter_captcha(FOne_char_image_size,
            image_background);

        //Gravar o caracter gerado em uma variavel
        image_characters := image_characters + captcha.character;

        // Adicione a imagem gerada à lista de imagens
        AListaImagem_Um_Caract.add(captcha.image);
      End;

    End;

{ TODO 2 -oRuan Diego Lacerda Menezes -cFunções : Função em Desenvolvimento }
//    inverter_caracter_imagem(captcha.image);

    // Junte as imagens dos caracteres horizontalmente em uma unica imagem
    juntar_imagens_na_horizontal(image, AListaImagem_Um_Caract);

    //Libera a Lista da Memoria
    AListaImagem_Um_Caract.Destroy;

    // Adicione uma linha aleatória horizontal à imagem completa
    for I := 0 to RandomRange(0, ADIFFICULT_LEVELS_VALUES[FNivelDificuldade][0]) do
    Begin
      //Gere uma cor de Auto Contraste em relação ao Plano de Fundo
      efeitos_background := gerar_cor_rand();


      add_linha_horizontal_rand_na_imagem(image, RandomRange(2, 5),
      efeitos_background);
    End;

    //Adicione alguns círculos aleatórios à imagem
    for I := 0 to RandomRange(0, ADIFFICULT_LEVELS_VALUES[FNivelDificuldade][1]) do
    Begin
      //Gerar uma cor de Auto Contraste em relação ao Plano de Fundo
      efeitos_background := gerar_cor_rand();

      add_circulo_rand_na_imagem(image,
      Round(0.05 * FOne_char_image_size.Width {X}),
      Round(0.15 * FOne_char_image_size.Height {Y}),
      efeitos_background);
    End;

    //Adicione alguns Traços aleatórios à imagem
    for I := 0 to RandomRange(0, ADIFFICULT_LEVELS_VALUES[FNivelDificuldade][0]) do
    Begin
      //Gerar uma cor de Auto Contraste em relação ao Plano de Fundo
      efeitos_background := gerar_cor_rand();

      add_traco_rand_na_imagem(image, RandomRange(2, 5),
      efeitos_background);
    End;

    //Adicione alguns Elipses aleatórios à imagem
    for I := 0 to RandomRange(0, ADIFFICULT_LEVELS_VALUES[FNivelDificuldade][1]) do
    Begin
      //Gerar uma cor de Auto Contraste em relação ao Plano de Fundo
      efeitos_background := gerar_cor_rand();

      add_elipse_rand_na_imagem(image,
      Round(0.05 * FOne_char_image_size.Width),
      Round(0.15 * FOne_char_image_size.Height),
      Round(0.02 * FOne_char_image_size.Width),
      Round(0.10 * FOne_char_image_size.Height),
      efeitos_background);
    End;

    //Adicione alguns Quadrados aleatórios à imagem
    for I := 0 to RandomRange(0, ADIFFICULT_LEVELS_VALUES[FNivelDificuldade][1]) do
    Begin
      //Gerar uma cor de Auto Contraste em relação ao Plano de Fundo
      efeitos_background := gerar_cor_rand();

      add_quadrados_rand_na_imagem(image,
      Round(0.02 * FOne_char_image_size.Width),
      Round(0.05 * FOne_char_image_size.Height),
      efeitos_background);
    End;

    // Adicionar margens horizontais
    if FUsarMargens then
    Begin
    { TODO 2 -oRuan Diego Lacerda Menezes -cBordas :
    Este metodo está emfase de reformulação e por isso não esta com
    os demais codigos ativos }
      with {new_image}image.Picture.Bitmap do
      Begin
        //new_image = Image.new('RGBA', self.captcha_size, "rgb(0, 0, 0)")
//        new_image := TImage.Create(image);
        Canvas.Brush.Color := RGB(0,0,0);
//        Width := image.Width {captcha_size[0]};
//        Height := image.Height {captcha_size[1]};
        //new_image.paste(image, (0, int((self.captcha_size[1]/2) - (image.height/2))))
//        Canvas.Draw(0,
//              Round((captcha_size[1] div 2) - (image.height div 2)),
//              image.Picture.Graphic);
//        image.Picture.Bitmap.Assign(new_image.Picture.Bitmap);
      End;
    End;


    // Retornar captcha de imagem gerada
    generated_captcha.image := TImage.Create(nil);
    generated_captcha.image := FCaptcha;

  End
  Else
    Showmessage('TImage Não Associado na Propriedade Captcha do Componente');

  generated_captcha.character := image_characters;
  result := generated_captcha;

  if Assigned(AoGerar) then
    AoGerar(Self);

end;

function TCaptchaGenerator.gerar_cor_rand(const min_val: Integer;
  max_val: Integer): TColor;
var
  R, G, B: Byte;
begin

R     := RandomRange(min_val, max_val);
G     := RandomRange(min_val, max_val);
B     := RandomRange(min_val, max_val);

result := RGB(R,G,B);


end;

function TCaptchaGenerator.gerar_cor_contraste_rand(from_color: TColor): TColor;
Var
  nivel_escuro, color : TColor;
begin

  nivel_escuro := nivel_contraste_da_cor(
                                  ComoRGB(from_color).R,
                                  ComoRGB(from_color).G,
                                  ComoRGB(from_color).B);
  color := RGB(0, 0, 0);

  if nivel_escuro = -3 then
      color := self.gerar_cor_rand(0, 42)
  else if nivel_escuro = -2 then
      color := self.gerar_cor_rand(42, 84)
  else if  nivel_escuro = -1 then
      color := self.gerar_cor_rand(84, 126)
  else if  nivel_escuro = 1 then
      color := self.gerar_cor_rand(126, 168)
  else if  nivel_escuro = 2 then
      color := self.gerar_cor_rand(168, 210)
  else if  nivel_escuro = 3 then
      color := self.gerar_cor_rand(210, 255);

  result := color;

end;

function TCaptchaGenerator.gerar_cor_contraste_custom(from_color: TColor): TColor;
Var
  dark_level, color : TColor;
begin

  color := clNone;

  // Get light-dark tonality level of the provided color
  dark_level := nivel_contraste_da_cor(
                            ComoRGB(from_color).R,
                            ComoRGB(from_color).G,
                            ComoRGB(from_color).B);
  // If it is a dark color
  if dark_level >= 1 then
      // from_color -> (255 - 384) -> (85 - 128)
      color := gerar_cor_rand(148, 255);
      // For high dark
      if dark_level = 3 then
          // from_color -> (0 - 128) -> (0 - 42)
          color := gerar_cor_rand(62, 255)
  // If it is a light color
  else if dark_level <= -1 then
      // from_color -> (384 - 640) -> (128 - 213)
      color := gerar_cor_rand(0, 108);
      // For high light
      if dark_level = -3 then
          // from_color -> (640 - 765) -> (213 - 255)
          color := gerar_cor_rand(0, 193);
  Result := color;

end;

function TCaptchaGenerator.gerar_fonte_rand(fonts_list: array of string): String;
var
  font_num: Integer;
begin

  font_num := RandomRange(0, length(fonts_list)-1);
  result := fonts_list[font_num];

end;

function TCaptchaGenerator.gerar_tamanho_rand_fonte(font_nome: String; min_size,
  max_size: Integer): TFont;
var
  font_size: integer;
  Fonte : TFont;
begin

  try
    font_size := RandomRange(min_size, max_size);
    Fonte := TFont.Create;
    try
        Fonte.Name := font_nome;
        Fonte.Size := font_size;
    except on E: Exception do
      Begin
        Showmessage('Fonte incompatível para o captcha. Usando Arial como padrão');
        Fonte.Name := 'Arial';
        Fonte.Size := font_size;
      End;
    end
  finally
    result := Fonte;
  end;


end;

function TCaptchaGenerator.juntar_imagens_na_horizontal(var image: TImage; list_images: TObjectList<TImage>): TImage;
var
  img : TImage;
  x_offset: Integer;
begin

  x_offset := 0;
  for img in list_images do
  Begin
    image.Picture.Bitmap.Canvas.Draw(x_offset, 0, img.Picture.Bitmap {Graphic});
    x_offset := x_offset + FOne_char_image_size.Width;
  End;

  result := image;

  if Assigned(AoJuntarImagens) then
    AoJuntarImagens(Self);

end;

procedure TCaptchaGenerator.Inicializar;
begin

  //Limite para não receber zero
  if FNumeroDeCaracteres <= 0 then
     FNumeroDeCaracteres := 1;

  // Limit provided captcha size num
  if FTamanhoCaptcha < 0 then
      FTamanhoCaptcha := 0
  else
  if FTamanhoCaptcha >= Length(ACAPTCHA_SIZE) then
      FTamanhoCaptcha := Length(ACAPTCHA_SIZE) - 1;

  // Get captcha size
  FCaptcha_size := ACAPTCHA_SIZE[FTamanhoCaptcha];

  // Determine one char image height
  if FNumeroDeCaracteres > 1 then
    FDiv_size := (FCaptcha_size[0] div FNumeroDeCaracteres)
  else
    FDiv_size := FCaptcha_size[0];

  if (FDiv_size - Round(FDiv_size)) <= 0.5 then
      FDiv_size := Round(FDiv_size)
  else
    FDiv_size := Round(FDiv_size) + 1;

  FOne_char_image_size := TSize.Create(One_char_image_size);

  //Definindo o tamanho de cada imagem de caracter
  FOne_char_image_size.Width {X} := Trunc(FDiv_size);
  FOne_char_image_size.Height{Y} := (FCaptcha_size[1]);

  // Determine font size according to image size
  FFont_size_min := AFONT_SIZE_RANGE[FTamanhoCaptcha][0];
  FFont_size_max := AFONT_SIZE_RANGE[FTamanhoCaptcha][1];

  FFont_size_range[0] := FFont_size_min;
  FFont_size_range[1] := FFont_size_max;

end;

procedure TCaptchaGenerator.inverter_caracter_imagem(var image : TImage);
var
  x,y: integer;
  P,Q: PByteArray;
  img2: TImage;
begin
{ TODO 2 -oRuan Diego -cFunções : Não esta funcionando ainda }
  img2 := TImage.Create(Self);

  Img2.Canvas.Draw(0,0,image.Picture.Graphic);
  for y:= 0 to image.Height -1 do
  begin
    P:= image.Picture.Bitmap.ScanLine[y];
    Q:= Img2.Picture.Bitmap.ScanLine[y];
    for x:= 0 to image.Width -1 do
    begin
      P[(x * 3) + 0]:= Q[(((image.Width -1) -x) * 3) + 0];
      P[(x * 3) + 1]:= Q[(((image.Width -1) -x) * 3) + 1];
      P[(x * 3) + 2]:= Q[(((image.Width -1) -x) * 3) + 2];
    end;
  end;
  image.Repaint;

end;

procedure TCaptchaGenerator.SetCaptcha(const Value: TImage);
begin
  FCaptcha := Value;
  FCaptcha.Picture.Bitmap.TransparentColor := clWhite;

  FAltura := FCaptcha.Height;
  FLargura := FCaptcha.Width;

  Inicializar;

end;

procedure TCaptchaGenerator.SetCharSetMODE(const Value: TCharSet_modes);
begin
  FCharSetMODE := Value;
end;

procedure TCaptchaGenerator.SetTamanhoCaptcha(const Value: Integer);
begin
  if Value >= (Length(ACAPTCHA_SIZE)) then
      FTamanhoCaptcha := Length(ACAPTCHA_SIZE) - 1
  else
    FTamanhoCaptcha := Value;

  Inicializar;
end;

function TCaptchaGenerator.ComoRGB(AForm_Color: TColor): TRGB;
begin
  with Result do
  Begin
    R := AForm_Color;
    G := AForm_Color shr 8;
    B := AForm_Color shr 16;
  End;
end;

end.
