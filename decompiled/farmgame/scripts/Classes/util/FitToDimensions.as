package Classes.util
{
   public class FitToDimensions
   {
      
      public static const CONSTRAIN_MINIMUM:Number = 0;
      
      public static const CONSTRAIN_MAXIMUM:Number = 1;
      
      public function FitToDimensions()
      {
         super();
      }
      
      public static function fitToDimensions(fStartWidth:Number, fStartHeight:Number, fConstrainWidth:Number, fConstrainHeight:Number, iConstrainMode:int) : Object
      {
         if(iConstrainMode != CONSTRAIN_MINIMUM && iConstrainMode != CONSTRAIN_MAXIMUM)
         {
            return {
               "width":fConstrainWidth,
               "height":fConstrainHeight
            };
         }
         if(fConstrainWidth > fConstrainHeight && fStartHeight > fStartWidth)
         {
            return fitToWidth(fStartWidth,fStartHeight,fConstrainWidth,fConstrainHeight,iConstrainMode);
         }
         if(fConstrainWidth > fConstrainHeight && fStartWidth > fStartHeight)
         {
            if(continueSizing(fStartHeight,fConstrainHeight,iConstrainMode))
            {
               return fitToHeight(fStartWidth,fStartHeight,fConstrainWidth,fConstrainHeight,iConstrainMode);
            }
            return fitToWidth(fStartWidth,fStartHeight,fConstrainWidth,fConstrainHeight,iConstrainMode);
         }
         if(fConstrainHeight > fConstrainWidth && fStartWidth > fStartHeight)
         {
            return fitToHeight(fStartWidth,fStartHeight,fConstrainWidth,fConstrainHeight,iConstrainMode);
         }
         if(fConstrainHeight > fConstrainWidth && fStartWidth > fStartHeight)
         {
            if(continueSizing(fStartWidth,fConstrainWidth,iConstrainMode))
            {
               return fitToWidth(fStartWidth,fStartHeight,fConstrainWidth,fConstrainHeight,iConstrainMode);
            }
            return fitToHeight(fStartWidth,fStartHeight,fConstrainWidth,fConstrainHeight,iConstrainMode);
         }
         return fitToWidth(fStartWidth,fStartHeight,fConstrainWidth,fConstrainHeight,iConstrainMode);
      }
      
      private static function fitToWidth(fStartWidth:Number, fStartHeight:Number, fConstrainWidth:Number, fConstrainHeight:Number, iConstrainMode:Number) : Object
      {
         var fOldDimension:Number = fStartWidth;
         fStartWidth = fConstrainWidth;
         fStartHeight *= fStartWidth / fOldDimension;
         if(continueSizing(fStartHeight,fConstrainHeight,iConstrainMode))
         {
            return fitToHeight(fStartWidth,fStartHeight,fConstrainWidth,fConstrainHeight,iConstrainMode);
         }
         return {
            "width":fStartWidth,
            "height":fStartHeight
         };
      }
      
      private static function fitToHeight(fStartWidth:Number, fStartHeight:Number, fConstrainWidth:Number, fConstrainHeight:Number, iConstrainMode:int) : Object
      {
         var fOldDimension:Number = fStartHeight;
         fStartHeight = fConstrainHeight;
         fStartWidth *= fStartHeight / fOldDimension;
         if(continueSizing(fStartWidth,fConstrainWidth,iConstrainMode))
         {
            return fitToWidth(fStartWidth,fStartHeight,fConstrainWidth,fConstrainHeight,iConstrainMode);
         }
         return {
            "width":fStartWidth,
            "height":fStartHeight
         };
      }
      
      private static function continueSizing(fDimension:Number, fConstrainDimension:Number, iConstrainMode:int) : Boolean
      {
         if(fDimension == 0)
         {
            return false;
         }
         if(iConstrainMode == CONSTRAIN_MINIMUM && fDimension < fConstrainDimension)
         {
            return true;
         }
         if(iConstrainMode == CONSTRAIN_MAXIMUM && fDimension > fConstrainDimension)
         {
            return true;
         }
         return false;
      }
   }
}

