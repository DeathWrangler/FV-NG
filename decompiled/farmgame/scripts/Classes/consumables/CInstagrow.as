package Classes.consumables
{
   import AvatarMode.AMAirplane;
   import Classes.Airplane;
   import Classes.Consumable;
   import Classes.Plot;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   import Managers.InstagrowHelper;
   import Managers.MapResourceHelper;
   
   public class CInstagrow extends Consumable
   {
      
      public function CInstagrow(itemName:String)
      {
         super(itemName);
      }
      
      override public function canUse() : Boolean
      {
         var plot:Plot = null;
         var errorDialogParams:Array = null;
         var result:Boolean = false;
         var plots:Array = Global.world.getObjectsByClass(Plot);
         for(var plotIdx:int = 0; plotIdx < plots.length; plotIdx++)
         {
            plot = plots[plotIdx] as Plot;
            if((plot.isPlanted() || plot.isGrown()) && !plot.isHarvestable())
            {
               result = true;
            }
         }
         if(!result)
         {
            errorDialogParams = [m_item.getImageByName("icon",false),ZLocUtils.t("Dialogs","Instagrow_Cannot_Use",{"item":ZLocUtils.tk_pk(m_item.friendlyName)})];
            UI.displayPopup(new DataDrivenOkayPopup("MotdNormal",errorDialogParams));
         }
         return result;
      }
      
      override public function onUse() : void
      {
         var airplaneName:String = Global.worldSettingsManager.getWorldSpecificPlaneItemName(Global.worldManager.currentWorldType,AMAirplane.DEFAULT_AIRPLANE_ITEM);
         var equipment:Airplane = new Airplane(airplaneName,true);
         equipment.setOuter(Global.world);
         Global.selectedAvatar.getStateMachine().addState(new AMAirplane(Global.selectedAvatar,new InstagrowHelper(MapResourceHelper.TYPE_PLOTS),equipment,false),true);
      }
   }
}

