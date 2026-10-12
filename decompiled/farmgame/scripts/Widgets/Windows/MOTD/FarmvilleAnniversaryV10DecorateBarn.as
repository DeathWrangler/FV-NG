package Widgets.Windows.MOTD
{
   import Classes.NurseryBuilding;
   import Classes.NurseryConstructionBuilding;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FarmvilleAnniversaryV10DecorateBarn extends GenericSingleButtonWidgetMOTD
   {
      
      public static const NURSERY_BARN_ANNIVERSARY_DECORATION:String = "NurseryBarnAnniversaryDecoration";
      
      public static const NURSERY_BARN_BUILT_NUMBER:String = "built";
      
      public static const NURSERY_BARN_BUILT_INCOMPLETE:String = "Ay";
      
      public static const NURSERY_BARN_BUILT_FINISHED:String = "Az";
      
      private var m_builtNo:String;
      
      private var m_barnMc:MovieClip;
      
      private var m_bodyTF:ZwTextField;
      
      private var m_titleTF:ZwTextField;
      
      private var m_barnIcons:Array = [];
      
      private var m_barnSelectBTs:Array = [];
      
      private var m_barnCheckmarksMCs:Array = [];
      
      public function FarmvilleAnniversaryV10DecorateBarn(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var index:int = 0;
         var barnSlot:MovieClip = null;
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               this.m_titleTF = addWidget(new ZwTextField(m_window.mainWindow["title_tf"],"Birthday Decorations!")) as ZwTextField;
               this.m_titleTF.visible = true;
            }
            if(m_window.mainWindow["body_tf"])
            {
               this.m_bodyTF = addWidget(new ZwTextField(m_window.mainWindow["body_tf"],"Choose a new look for the barn on your Home Farm, and celebrate Farmville’s 10th Birthday!")) as ZwTextField;
               this.m_bodyTF.visible = true;
            }
            if(m_window.mainWindow["body2_tf"])
            {
               (addWidget(new ZwTextField(m_window.mainWindow["body2_tf"],"You should have a Nursery Barn completed and placed on the Home Farm to see this change.")) as ZwTextField).visible = true;
            }
            if(m_window.mainWindow["barn_mc"])
            {
               this.m_barnMc = m_window.mainWindow["barn_mc"] as MovieClip;
               index = 0;
               while(this.m_barnMc["barn" + index.toString() + "_mc"])
               {
                  barnSlot = this.m_barnMc["barn" + index.toString() + "_mc"] as MovieClip;
                  if(barnSlot.hasOwnProperty("checkmark_mc"))
                  {
                     this.m_barnCheckmarksMCs[index] = barnSlot["checkmark_mc"] as MovieClip;
                     this.m_barnCheckmarksMCs[index].visible = false;
                  }
                  if(barnSlot.hasOwnProperty("selec_bt"))
                  {
                     this.m_barnSelectBTs[index] = new FarmAnimatedTextButton(barnSlot["selec_bt"],"This One!",this.onSelectbarnBuilt(index));
                     this.m_barnSelectBTs[index].visible = true;
                  }
                  if(barnSlot.hasOwnProperty("icon_mc"))
                  {
                     this.m_barnIcons[index] = new FarmIcon(barnSlot["icon_mc"]);
                     this.m_barnIcons[index].visible = true;
                  }
                  barnSlot.visible = true;
                  index++;
               }
               this.m_barnMc.visible = true;
            }
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Apply",this.onAccept)) as FarmAnimatedTextButton;
               m_accept_bt.enabled = false;
            }
         }
      }
      
      private function onSelectbarnBuilt(index:int) : Function
      {
         return function(event:Event):void
         {
            m_builtNo = (index + 1).toString();
            m_accept_bt.enabled = true;
            var i:* = 0;
            while(i < m_barnCheckmarksMCs.length)
            {
               m_barnCheckmarksMCs[i].visible = i == index;
               i++;
            }
         };
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         var applied:Boolean = false;
         var finishedBarn:NurseryBuilding = null;
         var incompleteBarn:NurseryConstructionBuilding = null;
         var placed:Boolean = false;
         var popup:GenericPopup = null;
         if(this.m_builtNo)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(NURSERY_BARN_ANNIVERSARY_DECORATION,NURSERY_BARN_BUILT_NUMBER,this.m_builtNo);
            FeatureOptionsManager.getInstance().save();
            applied = false;
            finishedBarn = Global.world.getObjectsByCode(NURSERY_BARN_BUILT_FINISHED)[0];
            incompleteBarn = Global.world.getObjectsByCode(NURSERY_BARN_BUILT_INCOMPLETE)[0];
            if(finishedBarn)
            {
               finishedBarn.reloadImage();
               applied = finishedBarn.isFullyBuilt();
            }
            if(incompleteBarn)
            {
               incompleteBarn.reloadImage();
               applied = finishedBarn.isFullyBuilt();
            }
            placed = Boolean(finishedBarn) || Boolean(incompleteBarn);
            FarmStatsManager.count("FVAnniversaryV10","decorate_barn",this.m_builtNo.toString(),placed.toString(),applied.toString(),Global.worldManager.currentWorldType);
            if(Global.worldManager.currentWorldType != "farm")
            {
               popup = new GenericPopup("Congratulations! Your Nursery Barn now has a new look! Go to your Home Farm to check it out!");
               popup.setAcceptTextName("Okay");
               UI.displayPopup(popup,false);
            }
         }
         super.onAccept(event);
      }
   }
}

