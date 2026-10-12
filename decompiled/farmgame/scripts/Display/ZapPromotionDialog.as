package Display
{
   import Classes.ZItem.FarmItem;
   import Managers.ZapPromoManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class ZapPromotionDialog extends FarmDynamicDialog
   {
      
      private var m_item:FarmItem;
      
      private var m_fbLikeUrl:String;
      
      public function ZapPromotionDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public function setDialogconfig(item:FarmItem, fbLikeUrl:String, title:String, topMessage:String, bottomMessage:String) : void
      {
         this.m_item = item;
         this.m_fbLikeUrl = fbLikeUrl;
         this.setShortcutAttribute("dialogTitle",TextFieldView.ATTRIBUTE_TEXT,title);
         this.setShortcutAttribute("dialogTopMessage",TextFieldView.ATTRIBUTE_TEXT,topMessage);
         this.setShortcutAttribute("dialogBottomMessage",TextFieldView.ATTRIBUTE_TEXT,bottomMessage);
      }
      
      override public function setup() : void
      {
         this.setShortcutListener("FBVisitButton",WidgetControllerEvent.BUTTON_PRESSED,this.onFBVisitButtonPressed);
         this.setShortcutListener("shareButton",WidgetControllerEvent.BUTTON_PRESSED,this.onSharePressed);
      }
      
      private function onFBVisitButtonPressed(event:WidgetControllerEvent) : void
      {
         ZapPromoManager.countEvent(this.m_item.brandPromoData.brandPromoName,"firstUseVisit",this.m_item.name);
         var request:URLRequest = new URLRequest(this.m_fbLikeUrl);
         try
         {
            navigateToURL(request,"_blank");
         }
         catch(e:Error)
         {
         }
      }
      
      private function onSharePressed(event:WidgetControllerEvent) : void
      {
         ZapPromoManager.countEvent(this.m_item.brandPromoData.brandPromoName,"firstUseShare",this.m_item.name);
         ZapPromoManager.shareFirstPlacement(this.m_item);
         destroy();
      }
   }
}

