package Display
{
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import flash.events.Event;
   
   public class GenericFrictionlessBuyPopup extends GenericIconPopup
   {
      
      public static const GENERIC_FRICTIONLESS_BUY_ASSET:String = "assets/dialogs/FV_GenericFrictionlessBuyPopup.swf";
      
      private var m_cost:String = "";
      
      public function GenericFrictionlessBuyPopup(message:String, type:int = 1, closeCallback:Function = null, icon:Object = null, disableIconResize:Boolean = false, showX:Boolean = true, additionalText:String = "", useHtmlText:Boolean = false, dialogAsset:String = "assets/dialogs/FV_GenericFrictionlessBuyPopup.swf", iconFilter:Array = null, forceSize:Boolean = false, cost:String = "")
      {
         super(message,type,closeCallback,icon,disableIconResize,showX,additionalText,useHtmlText,dialogAsset,iconFilter,forceSize);
         this.m_cost = cost;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_accept = new GenericFarmCashButton(m_window.popupBox_mc.okay_bt,onAccept);
         GenericFarmCashButton(m_accept).cost = this.m_cost;
         m_window.popupBox_mc.okay_bt.visible = true;
         if(this.m_type == GenericPopup.TYPE_FRICTIONLESS_BUYASK)
         {
            m_window.popupBox_mc.ask_bt.visible = true;
            m_reject = new GenericButton(m_window.popupBox_mc.ask_bt,this.onAsk);
            m_reject.text = ZLocUtils.t("Dialogs",m_cancelTextName);
         }
         else if(this.m_type == GenericPopup.TYPE_FRICTIONLESS_BUY)
         {
            m_window.popupBox_mc.okay_bt.x = (m_window.width - m_window.popupBox_mc.okay_bt.width) / 2;
         }
      }
      
      protected function onAsk(event:Event) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ASK));
      }
   }
}

