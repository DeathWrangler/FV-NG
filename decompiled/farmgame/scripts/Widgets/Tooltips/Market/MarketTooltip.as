package Widgets.Tooltips.Market
{
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.filters.DropShadowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class MarketTooltip extends FarmTextTooltip
   {
      
      public function MarketTooltip(text:String = "", textFunction:Function = null, refreshSeconds:uint = 0)
      {
         super(text,textFunction,refreshSeconds);
         m_backgroundAlpha = 1;
         m_backgroundColor = 16777215;
         m_backgroundCornerRadius = 10;
         m_borderAlpha = 1;
         m_borderColor = 11048294;
         m_borderThickness = 3;
         m_padding = 6;
      }
      
      override protected function createTextField() : void
      {
         m_textfield = new TextField();
      }
      
      override protected function get defaultTextFormat() : TextFormat
      {
         return new TextFormat("Arial",13,5325357,false);
      }
      
      override protected function refresh() : void
      {
         super.refresh();
         if(m_container != null)
         {
            m_container.filters = [new DropShadowFilter(4,45,0.4,10,10)];
         }
      }
   }
}

