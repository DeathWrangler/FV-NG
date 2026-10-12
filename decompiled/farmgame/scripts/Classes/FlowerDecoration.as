package Classes
{
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   
   public class FlowerDecoration extends Decoration
   {
      
      private const STATE_LIVE:String = "live";
      
      private const STATE_DROOP:String = "droop";
      
      private const DECORATION:String = "decoration";
      
      protected var m_plantTime:Number;
      
      public function FlowerDecoration(itemName:String = null)
      {
         super(itemName);
         m_objectType = WorldObjectTypes.DECORATION;
         setState(this.STATE_LIVE);
         m_typeName = this.DECORATION;
         this.m_plantTime = 0;
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         switch(state)
         {
            case this.STATE_LIVE:
               imageName = "live";
               break;
            case this.STATE_DROOP:
               imageName = "droop";
               break;
            default:
               imageName = super.getCurrentImageName();
         }
         return imageName;
      }
      
      protected function isDroopy() : Boolean
      {
         var alpha:Number = NaN;
         var droopPercentage:Number = 0;
         if(this.m_plantTime > 0)
         {
            alpha = (Global.worldTime - this.m_plantTime) / this.getLiveTime();
            alpha = Math.floor(alpha * 100);
            droopPercentage = Math.max(Math.min(alpha,100),0);
         }
         return 100 == droopPercentage;
      }
      
      protected function getLiveTime() : int
      {
         var daysToMilliseconds:Number = NaN;
         var item:XML = null;
         var result:int = 1;
         if(m_item)
         {
            daysToMilliseconds = Global.farmGameSettingsManager.inGameDaySeconds * 1000;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(m_item.hasPropertyInDataSource("liveTime"))
               {
                  result = m_item.getIntFromDataSource("liveTime") * daysToMilliseconds;
               }
            }
            else
            {
               item = m_item.xml;
               if(item)
               {
                  result = item.liveTime * daysToMilliseconds;
               }
            }
         }
         return result;
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         obj.plantTime = this.m_plantTime;
         return obj;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.m_plantTime = data.plantTime;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         if(this.STATE_LIVE == state)
         {
            if(this.isDroopy())
            {
               setState(this.STATE_DROOP);
            }
         }
         super.onUpdate(delta);
      }
      
      override protected function getMenuItems() : Array
      {
         if(this.getItem().allowDelete || this.isDroopy())
         {
            return [{
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            },{
               "label":ZLocUtils.t("FarmGame","Sell"),
               "action":SELL_OBJECT
            }];
         }
         return [{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         }];
      }
      
      override protected function updateToolTipText() : void
      {
         var frName:String = null;
         var notes:String = null;
         if(isHighlighted() && Boolean(m_item))
         {
            frName = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
            if(this.STATE_DROOP == state)
            {
               frName += "\n" + ZLocUtils.t("FarmGame","Droopy");
            }
            notes = m_item.tooltipNotes;
            if(notes != "")
            {
               frName += "\n" + notes;
            }
            setToolTip(frName);
            updateToolTipPosition();
         }
      }
   }
}

