package Display.Dialogs
{
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FriendSetRequirement;
   import Classes.ItemRequirement;
   import Classes.ZItem.ChangeFarmItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Managers.PartyManager;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.controller.ProgressBarController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class SurveyorDialog extends FarmDynamicDialog
   {
      
      private static const DEFAULT_FARM_ICON:String = "assets/farms/farm_12_icon.png";
      
      public function SurveyorDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         var friendSetRequirement:FriendSetRequirement = null;
         var requirements:Array = null;
         var gridX:int = 0;
         var gridY:int = 0;
         var farmItems:Array = null;
         var currentFarmItem:ChangeFarmItem = null;
         var changeFarmItem:ChangeFarmItem = null;
         var currentFarmIconPath:String = null;
         var requirement:ItemRequirement = null;
         var friendSetCode:String = null;
         var neededAmount:int = 0;
         var currentAmount:int = 0;
         var currentFriendSet:FriendSet = null;
         var percent:Number = NaN;
         var item:FarmItem = getImport("item");
         if(item)
         {
            requirements = item.requirements;
            if(requirements)
            {
               for each(requirement in requirements)
               {
                  if(requirement is FriendSetRequirement)
                  {
                     friendSetRequirement = requirement as FriendSetRequirement;
                     break;
                  }
               }
            }
            gridX = Global.world.getGridWidth();
            gridY = Global.world.getGridHeight();
            farmItems = Global.farmGameSettingsManager.getExpansionFarmItemsForCurrentWorld();
            for each(changeFarmItem in farmItems)
            {
               if(changeFarmItem.squares == gridX && changeFarmItem.squares == gridY)
               {
                  currentFarmItem = changeFarmItem;
                  break;
               }
            }
            currentFarmIconPath = DEFAULT_FARM_ICON;
            if(currentFarmItem)
            {
               currentFarmIconPath = currentFarmItem.iconRelativeUrl;
            }
            setShortcutAttribute("currentFarmImage",ImageController.ATTRIBUTE_SOURCE,currentFarmIconPath);
            setShortcutAttribute("nextFarmImage",ImageController.ATTRIBUTE_SOURCE,item.iconRelativeUrl);
         }
         if(friendSetRequirement)
         {
            friendSetCode = friendSetRequirement.friendSetCode;
            neededAmount = friendSetRequirement.targetAmount;
            currentAmount = 0;
            currentFriendSet = PartyManager.getInstance().getPartyObjectByCode(friendSetCode).friendSet;
            if(currentFriendSet)
            {
               currentAmount = currentFriendSet.numFriendsCompleted;
            }
            setShortcutAttribute("neededText",TextFieldView.ATTRIBUTE_TEXT,neededAmount.toString());
            setShortcutAttribute("helperCount",TextFieldView.ATTRIBUTE_TEXT,currentAmount.toString());
            percent = 0;
            if(neededAmount > 0)
            {
               percent = currentAmount / neededAmount;
            }
            if(percent > 1)
            {
               percent = 1;
            }
            setShortcutAttribute("bar",ProgressBarController.ATTRIBUTE_PERCENT,percent);
            setShortcutAttribute("costText",TextFieldView.ATTRIBUTE_TEXT,item.cash.toString());
            setShortcutAttribute("surveyText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Surveyor_NeedHelp"));
            setShortcutAttribute("nextExpansionText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Surveyor_NextExpansion"));
            setShortcutAttribute("currentExpansionText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Surveyor_CurrentFarm"));
            setShortcutAttribute("helpersText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Surveyor_Helpers"));
            setShortcutAttribute("buyText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Skip"));
            setShortcutAttribute("InviteButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("FarmGame","AddNeighbor"));
            setShortcutListener("InviteButton",WidgetControllerEvent.BUTTON_PRESSED,this.onInviteFriends);
            setShortcutListener("buyButton",WidgetControllerEvent.BUTTON_PRESSED,this.onBuyPressed);
         }
      }
      
      private function onInviteFriends(event:WidgetControllerEvent) : void
      {
      }
      
      private function onBuyPressed(event:WidgetControllerEvent) : void
      {
         var item:ChangeFarmItem = getImport("item");
         if(item)
         {
            if(Global.player.canBuyCash(item.cash,true))
            {
               this.destroy();
               item.onBuy(item.cashName);
            }
         }
      }
   }
}

