package Widgets.Windows
{
   import Classes.AdItem;
   import Engine.Utilities;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class GenericAdToaster extends AutoCloseToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_GenericBannerAd.swf";
      
      private var m_ad:AdItem = null;
      
      protected var m_title:String;
      
      protected var m_message:String;
      
      public function GenericAdToaster(ad:AdItem = null)
      {
         if(ad)
         {
            this.m_ad = ad;
            this.m_title = ad.title;
            this.m_message = ad.desc;
         }
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Boolean(m_window) && Boolean(m_window.bannerad_mc))
         {
            m_window.bannerad_mc.visible = true;
            addWidget(new ZwTextField(m_window.bannerad_mc.generic_tf,this.m_title));
            addWidget(new ZwTextField(m_window.bannerad_mc.generic_desc_tf,this.m_message));
            addWidget(new FarmButton(m_window.bannerad_mc.close_bt,onClose));
            addWidget(new FarmButton(m_window.bannerad_mc.hitbox_mc,this.onHitBoxAction));
         }
      }
      
      protected function onHitBoxAction(event:Event) : void
      {
         var url:String = null;
         var uid:String = null;
         if(this.m_ad)
         {
            url = this.m_ad.link;
            if(url != "" && url.indexOf("{*uid*}") >= 0)
            {
               uid = Global.player.uid;
               if(!isNaN(Number(uid)) && uid != "0")
               {
                  url = url.replace("{*uid*}",uid);
                  Utilities.launchURL(url,"_blank",null);
               }
            }
         }
      }
   }
}

