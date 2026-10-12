package Display.Party
{
   import Classes.Constants.MFSConstants;
   import Classes.Constants.XMLKeys;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.PartyDataObject;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Managers.PartyManager;
   import Widgets.Frames.Party.PartyDanceFloorFrame;
   import Widgets.Windows.MFSFriendSet;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PartyDialog extends FarmDynamicDialog
   {
      
      protected var m_friendSetCode:String = "";
      
      protected var m_featureName:String = "";
      
      protected var m_statsCounterName:String = "";
      
      protected var m_mfsDisplayItemName:String = "";
      
      protected var m_isSetup:Boolean = false;
      
      protected var m_cashAmountToSkip:int = 0;
      
      protected var m_partyDataObj:PartyDataObject;
      
      protected var m_whatsThisDialog:FarmDynamicDialog = null;
      
      public function PartyDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         var xml:XML;
         var friendSet:FriendSet;
         var loadingDialog:GenericDialog = null;
         this.m_partyDataObj = PartyManager.getInstance().getPartyObjectByCode(this.m_friendSetCode);
         xml = Global.farmGameSettingsManager.getFriendSetXMLByCode(this.m_friendSetCode);
         if(xml.hasOwnProperty(XMLKeys.ATTR_NAME))
         {
            this.m_featureName = xml[XMLKeys.ATTR_NAME];
         }
         if(xml.hasOwnProperty(XMLKeys.ATTR_CODE))
         {
            this.m_friendSetCode = xml[XMLKeys.ATTR_CODE];
         }
         if(xml.hasOwnProperty("statsCounter"))
         {
            this.m_statsCounterName = xml["statsCounter"];
         }
         if(xml.hasOwnProperty("mfsDisplayItemName"))
         {
            this.m_mfsDisplayItemName = xml["mfsDisplayItemName"];
         }
         friendSet = this.m_partyDataObj.friendSet;
         if(Boolean(this.m_partyDataObj) && this.m_partyDataObj.isInitialized)
         {
            this.setupWindow();
         }
         else
         {
            this.m_isSetup = false;
            loadingDialog = UI.showMessage(ZLocUtils.t("Dialogs","TeaPartyLoadingMessage"));
            this.m_partyDataObj.addEventListener(Event.COMPLETE,function(event:Event):void
            {
               event.target.removeEventListener(event.type,arguments.callee);
               loadingDialog.destroy();
               setup();
               show();
            });
         }
      }
      
      protected function setupWindow() : void
      {
         this.setShortcutAttribute("InviteButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyInviteMore"));
         this.setShortcutListener("InviteButton",WidgetControllerEvent.BUTTON_PRESSED,this.onInvite);
         this.m_isSetup = true;
      }
      
      protected function setupAvatarView(controller:BaseWidgetController) : void
      {
         var partyFrameWidget:PartyDanceFloorFrame = null;
         var view:BaseWidgetView = controller.getView();
         var partyFarme:MovieClip = view.getChildAt(0) as MovieClip;
         if(partyFarme)
         {
            partyFrameWidget = new PartyDanceFloorFrame(partyFarme.progressFrame_mc.avatarFrame_mc,this.m_friendSetCode);
            partyFrameWidget.visible = true;
         }
      }
      
      protected function setupGuestInfo() : void
      {
         var currentGuests:int = this.m_partyDataObj.friendSet.numFriendsCompleted;
         var maxGuests:int = this.m_partyDataObj.goal.maxRequiredFriends;
         if(currentGuests > maxGuests)
         {
            currentGuests = maxGuests;
         }
         this.setShortcutAttribute("helpersText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Guests"));
         this.setShortcutAttribute("helpersCount",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","MeterCount",{
            "quantity":currentGuests,
            "maximum":maxGuests
         }));
      }
      
      public function onInvite(event:WidgetControllerEvent) : void
      {
         if(Utilities.isFullScreen())
         {
            Utilities.setFullScreen(false);
         }
         FarmStatsManager.count(this.getCounter(),"dialog","click_invite");
         var reqItemCrew:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getMfsDisplayItemName());
         var friendSpec:Object = {
            "tabNameSuggested":[MFSConstants.TYPE_SUGGESTED],
            "tabNameFarmVille":[MFSConstants.TYPE_FARMVILLE],
            "tabNameFacebook":[MFSConstants.TYPE_FACEBOOK]
         };
         var friendTabOrder:Array = ["tabNameSuggested","tabNameFarmVille","tabNameFacebook"];
         UI.displayPopup(new MFSFriendSet(friendSpec,friendTabOrder,reqItemCrew,this.getFeatureName(),this.getFriendSetCode(),String(-2),"",null),false);
      }
      
      protected function getCounter() : String
      {
         return this.m_statsCounterName;
      }
      
      protected function getFriendSetCode() : String
      {
         return this.m_friendSetCode;
      }
      
      protected function getFeatureName() : String
      {
         return this.m_featureName;
      }
      
      protected function getMfsDisplayItemName() : String
      {
         return this.m_mfsDisplayItemName;
      }
      
      override public function destroy() : void
      {
         PartyManager.getInstance().partyWindowOpen = false;
         super.destroy();
      }
   }
}

