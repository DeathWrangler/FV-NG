package Widgets.Windows.MOTD
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import flash.events.Event;
   
   public class SocialRaffleMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private const TEXT_PLAYNOW:String = "PlayNow";
      
      private const TEXT_PLACENOW:String = "PlaceNow";
      
      public function SocialRaffleMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var objects:Array = null;
         super.onLoadComplete(event);
         if(Boolean(m_currentMOTD.freeGift) && Boolean(m_accept_bt))
         {
            objects = Global.world.getObjectsByName(m_currentMOTD.freeGift);
            if(Boolean(objects) && objects.length > 0)
            {
               m_accept_bt.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_PLAYNOW);
            }
            else
            {
               m_accept_bt.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_PLACENOW);
            }
         }
      }
   }
}

