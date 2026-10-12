package Widgets.Windows.SocialRaffle
{
   import Classes.SocialRaffle.SocialRaffleConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.SocialRaffleManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.SocialRaffle.RaffleCrewSlotFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   
   public class SocialRaffleStatusWindow extends FarmWindow
   {
      
      private var FILE_NAME:String = "assets/dialogs/FV_SocialRaffle_StatusDialog.swf";
      
      private var TEXTFIELDS_INFO:Array = [{
         "name":"title1_tf",
         "pkg":"Dialogs",
         "key":"socialrafflebuilding_status_title1"
      },{
         "name":"subtitle_tf",
         "pkg":"Dialogs",
         "key":"socialrafflebuilding_status_subtitle"
      }];
      
      private var m_textFields:Object = {};
      
      public function SocialRaffleStatusWindow()
      {
         super(this.FILE_NAME);
      }
      
      override protected function postLoadComplete() : void
      {
         var friendAcceptsArray:Array = null;
         var i:int = 0;
         var txt:Object = null;
         var okaybt:FarmAnimatedTextButton = null;
         super.postLoadComplete();
         var raffleManager:Object = SocialRaffleManager.getInstance();
         var friendData:Array = [];
         if(Boolean(raffleManager) && Boolean(raffleManager.raffleDataView) && Boolean(raffleManager.raffleDataView.friendAccepts))
         {
            friendAcceptsArray = raffleManager.raffleDataView.friendAccepts[raffleManager.raffleDataView.getAdjustedDayOfWeek() - 1];
            for(i = 0; i < friendAcceptsArray.length; i++)
            {
               friendData.push({
                  "friendUid":friendAcceptsArray[i],
                  "slotNum":i
               });
            }
         }
         var rcsf:RaffleCrewSlotFrame = new RaffleCrewSlotFrame(m_window.gametickets_mc,friendData,"gameticket","_mc");
         this.addWidget(rcsf);
         rcsf.visible = true;
         var idx:int = 0;
         while(idx < this.TEXTFIELDS_INFO.length)
         {
            txt = this.TEXTFIELDS_INFO[idx];
            if(m_window[txt["name"]])
            {
               this.addWidget(this.m_textFields[txt["name"]] = new FarmTextField(m_window[txt["name"]],ZLocUtils.t(txt["pkg"],txt["key"])));
               this.m_textFields[txt["name"]].visible = true;
            }
            idx++;
         }
         var textField:FarmTextField = null;
         if(m_window["number_tf"])
         {
            textField = new FarmTextField(m_window["number_tf"],friendData.length.toString());
            this.addWidget(textField);
         }
         if(m_window["title2_tf"])
         {
            textField = new FarmTextField(m_window["title2_tf"],ZLocUtils.t("Dialogs","socialrafflebuilding_status_title2",{"ticket_word_lower":ZLocUtils.tk("Dialogs","ticket_word_lower","",friendData.length)}));
            this.addWidget(textField);
         }
         if(m_window.okay_bt)
         {
            okaybt = new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Dialogs","Okay"),onClose);
            this.addWidget(okaybt);
            okaybt.visible = true;
         }
         FarmStatsManager.count(SocialRaffleConstants.STATS_COUNTER,"summary_displayed",friendData.length.toString());
      }
   }
}

