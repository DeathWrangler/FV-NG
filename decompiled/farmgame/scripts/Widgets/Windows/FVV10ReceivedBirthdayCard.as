package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FVV10ReceivedBirthdayCard extends FarmWindow
   {
      
      private var m_giftData:Object;
      
      public function FVV10ReceivedBirthdayCard(giftData:Object)
      {
         super("assets/dialogs/Farmville10thBirthday/Birthday_card/reward.swf");
         this.m_giftData = giftData;
      }
      
      override protected function postLoadComplete() : void
      {
         var popupMC:MovieClip = null;
         var acceptBT:FarmAnimatedTextButton = null;
         var message:String = null;
         var icon:FarmIcon = null;
         var giftItem:FarmItem = null;
         var from:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("popup_mc"))
         {
            popupMC = m_window["popup_mc"] as MovieClip;
            if(popupMC.hasOwnProperty("accept_bt"))
            {
               acceptBT = addWidget(new FarmAnimatedTextButton(popupMC.accept_bt,"Awesome!",this.onAccept)) as FarmAnimatedTextButton;
               acceptBT.visible = true;
            }
            if(popupMC.hasOwnProperty("message_tf"))
            {
               message = Boolean(this.m_giftData) && Boolean(this.m_giftData.message) ? this.m_giftData.message : "";
               (addWidget(new ZwTextField(popupMC.message_tf,message)) as ZwTextField).visible = true;
            }
            if(popupMC.hasOwnProperty("icon_mc"))
            {
               icon = new FarmIcon(popupMC.icon_mc);
               if(Boolean(this.m_giftData) && Boolean(this.m_giftData.itemName))
               {
                  giftItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_giftData.itemName);
                  if(giftItem)
                  {
                     icon.loadIcon(giftItem.icon);
                     icon.setIconSize(70,70);
                     icon.setSmoothing(true);
                     icon.visible = true;
                     if(popupMC.hasOwnProperty("subtitle_tf"))
                     {
                        from = Boolean(this.m_giftData) && Boolean(this.m_giftData.from) ? this.m_giftData.from : "";
                        (addWidget(new ZwTextField(popupMC.subtitle_tf,"Your friend " + from + " has sent you " + giftItem.friendlyTitle + ". Enjoy!")) as ZwTextField).visible = true;
                     }
                  }
               }
            }
            popupMC.visible = true;
         }
      }
      
      private function onAccept(event:Event) : void
      {
         close();
      }
   }
}

