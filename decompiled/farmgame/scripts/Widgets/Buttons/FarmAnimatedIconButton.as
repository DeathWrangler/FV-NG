package Widgets.Buttons
{
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   
   public class FarmAnimatedIconButton extends FarmAnimatedButton
   {
      
      private var m_iconUrl:String = null;
      
      private var m_farmIcon:FarmIcon = null;
      
      public function FarmAnimatedIconButton(element:MovieClip, iconUrl:String = null, callback:Function = null, autoSize:Boolean = false, onLoadCallback:Function = null)
      {
         super(element,callback,autoSize);
         this.m_iconUrl = iconUrl;
         var innerElement:MovieClip = new MovieClip();
         this.m_farmIcon = new FarmIcon(innerElement);
         if(this.m_iconUrl != null && this.m_iconUrl != "")
         {
            this.m_farmIcon.loadIcon(this.m_iconUrl,onLoadCallback);
         }
         m_element.addChild(innerElement);
      }
      
      public function get farmIcon() : FarmIcon
      {
         return this.m_farmIcon;
      }
   }
}

