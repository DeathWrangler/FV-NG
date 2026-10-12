package Widgets.Windows.CrossPromo
{
   import Classes.CrossPromoDescriptor;
   import Classes.CrossPromoDescriptorManager;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.AutoCloseToasterWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class CrossPromoDescriptorToasterWindow extends AutoCloseToasterWindow
   {
      
      protected var m_crossPromoDescriptor:CrossPromoDescriptor;
      
      public function CrossPromoDescriptorToasterWindow(descriptor:CrossPromoDescriptor)
      {
         this.m_crossPromoDescriptor = descriptor;
         super(this.m_crossPromoDescriptor.toasterAsset,10000);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         FarmStatsManager.count("toaster","xpromo","view",this.promoGameID,this.promoName);
      }
      
      override protected function postLoadComplete() : void
      {
         var title:String = null;
         var text:String = null;
         super.postLoadComplete();
         if(Boolean(m_window.title_tf) && this.crossPromoDescriptor.toasterTitle != null)
         {
            title = ZLocUtils.tk_pk(this.crossPromoDescriptor.toasterTitle).getString();
            addWidget(new ZwTextField(m_window.title_tf,title));
         }
         if(Boolean(m_window.message_tf) && this.crossPromoDescriptor.toasterText != null)
         {
            text = ZLocUtils.tk_pk(this.crossPromoDescriptor.toasterText).getString();
            addWidget(new ZwTextField(m_window.message_tf,text));
         }
         if(m_window.hitbox_mc)
         {
            addWidget(new ZwWidget(m_window.hitbox_mc));
            (m_window.hitbox_mc as MovieClip).buttonMode = true;
            (m_window.hitbox_mc as MovieClip).addEventListener(MouseEvent.CLICK,this.onAccept);
         }
      }
      
      protected function get crossPromoDescriptor() : CrossPromoDescriptor
      {
         return this.m_crossPromoDescriptor;
      }
      
      protected function get promoName() : String
      {
         return this.crossPromoDescriptor.promoName;
      }
      
      protected function get promoGameID() : String
      {
         return this.crossPromoDescriptor.gameID;
      }
      
      private function onAccept(event:Event) : void
      {
         var playUrl:String = null;
         if(this.crossPromoDescriptor.shouldRedirectOnClick)
         {
            playUrl = this.m_crossPromoDescriptor.toasterPlayUrl != null ? this.m_crossPromoDescriptor.toasterPlayUrl : this.m_crossPromoDescriptor.playUrl;
            GlobalEngine.socialNetwork.redirect(playUrl,null,this.m_crossPromoDescriptor.targetWindow,false);
         }
         else
         {
            UI.displayPopup(new CrossPromoDescriptorWindow(this.crossPromoDescriptor),true,this.promoName + "_dialog",true);
         }
         FarmStatsManager.count("toaster","xpromo","click",this.promoGameID,this.promoName);
         this.setPromoSeenFlag();
         super.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("toaster","xpromo","x",this.promoGameID,this.promoName);
         this.setPromoSeenFlag();
         super.close();
      }
      
      private function setPromoSeenFlag() : void
      {
         CrossPromoDescriptorManager.setToasterSeenFlag(this.m_crossPromoDescriptor);
      }
   }
}

