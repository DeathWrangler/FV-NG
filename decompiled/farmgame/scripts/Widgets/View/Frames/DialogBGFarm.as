package Widgets.View.Frames
{
   import Classes.EmbeddedArt;
   import Engine.Utilities;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class DialogBGFarm extends DialogBGBase
   {
      
      public function DialogBGFarm(aKeyValuePairs:Array, nWidth:Number, nHeight:Number, bDrawShadow:Boolean = true, sColorStyle:String = "Blue")
      {
         super(aKeyValuePairs,nWidth,nHeight,bDrawShadow,sColorStyle);
      }
      
      override public function CreateBG(nWidth:Number, nHeight:Number, bDrawShadow:Boolean = true, sColorStyle:String = "Blue", sColorSubStyle:String = "_") : Sprite
      {
         var halfThick:Number = NaN;
         var mask:Sprite = null;
         var asset:DisplayObject = null;
         m_widthNoShadow = nWidth;
         m_heightNoShadow = nHeight;
         var pSprite:Sprite = new Sprite();
         Utilities.toggleInputOnlySelf(pSprite,false);
         var Color_ShadowBG:Number = 0;
         var Color_ShadowBGAlpha:Number = 0.6;
         var Color_BG:Number = 15392205;
         var Color_Line:Number = 7361594;
         var nDropShadowOffset:Number = 6.5;
         var nCornerRadius:Number = 15;
         var nLineThickness:Number = 4;
         var nX:Number = 0;
         var nY:Number = 0;
         if(bDrawShadow)
         {
            pSprite.graphics.beginFill(Color_ShadowBG,Color_ShadowBGAlpha);
            pSprite.graphics.drawRoundRect(nX + nDropShadowOffset,nY + nDropShadowOffset,nWidth,nHeight,nCornerRadius,nCornerRadius);
            pSprite.graphics.endFill();
         }
         pSprite.graphics.beginFill(Color_BG,1);
         pSprite.graphics.lineStyle(nLineThickness,Color_Line);
         pSprite.graphics.drawRoundRect(nX,nY,m_widthNoShadow,m_heightNoShadow,nCornerRadius,nCornerRadius);
         pSprite.graphics.endFill();
         var embeddedWoodClass:Class = EmbeddedArt.wood_grain;
         if(embeddedWoodClass)
         {
            halfThick = nLineThickness * 0.5;
            mask = new Sprite();
            mask.graphics.beginFill(Color_BG,1);
            mask.graphics.drawRoundRect(0,0,m_widthNoShadow - nLineThickness,m_heightNoShadow - nLineThickness,nCornerRadius,nCornerRadius);
            mask.graphics.endFill();
            mask.x = nX + halfThick;
            mask.y = nY + halfThick;
            pSprite.addChild(mask);
            asset = new embeddedWoodClass();
            asset.mask = mask;
            if(asset.height < nHeight)
            {
               asset.height = nHeight;
               asset.scaleX = asset.scaleY;
            }
            pSprite.addChild(asset);
         }
         return pSprite;
      }
   }
}

