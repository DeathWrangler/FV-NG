package Widgets.Frames.Crafting
{
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Crafting.ChooseCottageWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ChooseCottageSlotFrame extends ZwSlotFrame
   {
      
      private var m_mainWindow:ChooseCottageWindow;
      
      private var m_craftType:String;
      
      public function ChooseCottageSlotFrame(element:MovieClip, mainWindow:ChooseCottageWindow, craftType:String)
      {
         super(element);
         this.m_mainWindow = mainWindow;
         this.m_craftType = craftType;
         var friendsWithCottage:int = MarketViewManager.getInstance().getNumberOfFriendsWithCraftType(craftType);
         var craftBuildingName:String = ZLocUtils.t("Crafting","CraftName_" + craftType);
         addWidget(new ZwTextField(element.generic1_tf,craftBuildingName));
         var failoverEntryArray:Array = new Array();
         var params:Object = {
            "quantity":friendsWithCottage,
            "building_name":craftBuildingName
         };
         if(friendsWithCottage == 0)
         {
            failoverEntryArray.push(new ZLocFailoverEntry("Crafting","ChooseCraftDescNone_" + craftType));
            failoverEntryArray.push(new ZLocFailoverEntry("Crafting","ChooseCraftDescNone_failoverDefault"));
         }
         else if(friendsWithCottage == 1)
         {
            failoverEntryArray.push(new ZLocFailoverEntry("Crafting","ChooseCraftDescSingle_" + craftType));
            failoverEntryArray.push(new ZLocFailoverEntry("Crafting","ChooseCraftDescSingle_failoverDefault"));
         }
         else
         {
            failoverEntryArray.push(new ZLocFailoverEntry("Crafting","ChooseCraftDesc_" + craftType));
            failoverEntryArray.push(new ZLocFailoverEntry("Crafting","ChooseCraftDesc_failoverDefault"));
         }
         addWidget(new ZwTextField(element.generic2_tf,ZLocUtils.getFailoverLocString(failoverEntryArray,params)));
         addWidget(new FarmAnimatedTextButton(element.moreInfo_bt,ZLocUtils.t("Crafting","ChooseCraftLearnMore"),this.onClickLearn));
         addWidget(new FarmAnimatedTextButton(element.choose_bt,ZLocUtils.t("Crafting","ChooseCraftSignUp"),this.onClickPlace));
      }
      
      private function onClickLearn(event:Event) : void
      {
         FarmStatsManager.count("crafting_cottage","onboarding","standard_popup","click_more_info",this.m_craftType);
         this.m_mainWindow.showCraftDetailFrame(this.m_craftType);
      }
      
      private function onClickPlace(event:Event) : void
      {
         FarmStatsManager.count("crafting_cottage","onboarding","standard_popup","click_choose",this.m_craftType);
         this.m_mainWindow.close();
         CraftingManager.getInstance().claimFreeCottage(this.m_craftType,this.onSuccessfulPlace);
      }
      
      private function onSuccessfulPlace() : void
      {
         FarmStatsManager.count("crafting_cottage","onboarding","standard_popup","place",this.m_craftType);
      }
   }
}

