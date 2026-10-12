package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.ZapPromoManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class BrandPromoWindow extends FarmWindow
   {
      
      private var m_item:FarmItem = null;
      
      public function BrandPromoWindow(item:FarmItem)
      {
         super(item.brandPromoData.swf);
         this.m_item = item;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs",this.m_item.name + "_FirstPlacementTopMsg")),true);
         }
         if(m_window.hasOwnProperty("visit_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.visit_bt,ZLocUtils.t("Dialogs","FBVisit"),this.visitCallback),true);
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","GenericShareButton"),this.shareCallback),false);
         }
      }
      
      private function visitCallback(event:MouseEvent) : void
      {
         ZapPromoManager.countEvent(this.m_item.brandPromoData.brandPromoName,"firstUseVisit",this.m_item.name);
         var request:URLRequest = new URLRequest(this.m_item.brandPromoData.brandUrl);
         try
         {
            navigateToURL(request,"_blank");
         }
         catch(e:Error)
         {
         }
         if(m_window.hasOwnProperty("visit_bt"))
         {
            getWidget(m_window.visit_bt).visible = false;
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            getWidget(m_window.share_bt).visible = true;
         }
      }
      
      private function shareCallback(event:MouseEvent) : void
      {
         ZapPromoManager.countEvent(this.m_item.brandPromoData.brandPromoName,"firstUseShare",this.m_item.name);
         ZapPromoManager.shareFirstPlacement(this.m_item);
         this.close();
      }
   }
}

