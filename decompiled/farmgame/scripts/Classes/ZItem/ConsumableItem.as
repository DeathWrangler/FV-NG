package Classes.ZItem
{
   import Classes.AutoConsumable;
   import Classes.Consumable;
   import DataSources.BaseDataSource;
   import GameMode.GMCSlotMachineToken;
   import GameMode.GMSuperPlot;
   import GameMode.GMTargetedConsumable;
   import Managers.FarmGameSettingsManager;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class ConsumableItem extends FarmItem
   {
      
      protected var m_buildingName:String = null;
      
      protected var m_buffExpires:Number;
      
      protected var m_plantTimeRatio:Number;
      
      protected var m_bushelMultiplier:Number;
      
      protected var m_masteryBonus:Number;
      
      private var m_typeClassNames:Object = {
         "superplot":GMSuperPlot,
         "token":GMCSlotMachineToken,
         "targeted":GMTargetedConsumable
      };
      
      public function ConsumableItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      public function get buildingName() : String
      {
         if(this.m_buildingName == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_buildingName = m_dataSource.getString("buildingName");
            }
            else
            {
               this.m_buildingName = m_itemXML.@buildingName.toString();
            }
         }
         return this.m_buildingName;
      }
      
      public function get buffExpires() : Number
      {
         if(!this.m_buffExpires)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_buffExpires = m_dataSource.getNumber("buffExpires");
            }
            else
            {
               this.m_buffExpires = Number(m_itemXML.buffExpires.toString());
            }
         }
         return this.m_buffExpires;
      }
      
      public function get plantTimeRatio() : Number
      {
         if(!this.m_plantTimeRatio)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_plantTimeRatio = m_dataSource.getNumber("plantTimeRatio");
            }
            else
            {
               this.m_plantTimeRatio = Number(m_itemXML.plantTimeRatio.toString());
            }
         }
         return this.m_plantTimeRatio;
      }
      
      public function get masteryBonus() : Number
      {
         if(!this.m_masteryBonus)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_masteryBonus = m_dataSource.getNumber("masteryBonus");
            }
            else
            {
               this.m_masteryBonus = Number(m_itemXML.masteryBonus.toString());
            }
         }
         return this.m_masteryBonus;
      }
      
      public function get bushelMultiplier() : Number
      {
         if(!this.m_bushelMultiplier)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_bushelMultiplier = m_dataSource.getNumber("bushelMultiplier");
            }
            else
            {
               this.m_bushelMultiplier = Number(m_itemXML.bushelMultiplier.toString());
            }
         }
         return this.m_bushelMultiplier;
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var consumable:Consumable = Consumable.createConsumable(name,{"isGift":false});
         if(consumable.canUse())
         {
            consumable.onUse();
         }
         return true;
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         var className:String = null;
         var classType:Class = null;
         var itemCount:int = 0;
         var autoConsumable:AutoConsumable = null;
         var consumable:Consumable = null;
         var isGift:Boolean = true;
         if(Boolean(extraData) && Boolean(extraData.isGift != null) && extraData.isGift == false)
         {
            isGift = false;
         }
         var allowReshopping:Boolean = true;
         if(Boolean(extraData) && Boolean(extraData.allowReshopping != null) && extraData.allowReshopping == false)
         {
            allowReshopping = false;
         }
         if(this.m_typeClassNames.hasOwnProperty(subType))
         {
            className = getQualifiedClassName(this.m_typeClassNames[subType]);
            classType = getDefinitionByName(className) as Class;
            Global.world.addGameMode(new classType(name,isGift));
         }
         else
         {
            itemCount = 1;
            if(Boolean(extraData) && extraData.hasOwnProperty("itemCount"))
            {
               itemCount = int(extraData.itemCount);
            }
            if(this.isAutoConsumable())
            {
               autoConsumable = AutoConsumable.createAutoConsumable(name);
               autoConsumable.consume();
            }
            else
            {
               consumable = Consumable.createConsumable(name);
               consumable.consume(true,allowReshopping,"",false,-1,itemCount);
            }
         }
      }
      
      public function useOnBuy() : Boolean
      {
         var useOnBuyAttr:XMLList = null;
         var result:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_dataSource.hasProperty("useOnBuy"))
            {
               result = m_dataSource.getBoolean("useOnBuy");
            }
         }
         else
         {
            useOnBuyAttr = xml.attribute("useOnBuy");
            if(useOnBuyAttr.length() > 0)
            {
               result = String(xml.@useOnBuy) == "true" ? true : false;
            }
         }
         return result;
      }
      
      public function isAutoConsumable() : Boolean
      {
         var result:Boolean = false;
         if(AutoConsumable.createAutoConsumable(name))
         {
            result = true;
         }
         return result;
      }
   }
}

