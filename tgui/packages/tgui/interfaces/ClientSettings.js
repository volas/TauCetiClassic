import { useBackend } from '../backend';

/* todo */
import { Section, Box, Button, Input, NumberInput, Tabs, Dropdown, Flex, Slider, NoticeBox, ColorBox } from '../components';

import { Window } from '../layouts';

export const ClientSettings = (props, context) => {
  const { act, data } = useBackend(context);

  const { active_tab, settings } = data;

  const tabs = {
    ui: "Интерфейс",
    graphics: "Графика",
    audio: "Аудио",
    chat: "Чат",
    other: "Разное",
    keybinds: "Управление",
  };
  const tabs_description = {
    ui: "Рекомендуется изменять настройки во время игры - так вы сможете предварительно увидить результаты эффектов.",
    graphics: "Рекомендуется изменять настройки во время игры - так вы сможете предварительно увидить результаты эффектов.",
    audio: "Вы можете единожды нажать на слайдер и ввести точное значение.",
  };

  return (
    <Window
      title="Настройки"
      width={500}
      height={500}>
      <Window.Content>
        <Tabs>
          {Object.keys(tabs).map(tab => (
            <Tabs.Tab
              key={tab}
              selected={tab === active_tab}
              onClick={() => act("mode", { mode: 0 })} >
              {tabs[tab]}
            </Tabs.Tab>
          ))}
        </Tabs>
        {tabs_description[active_tab] && (
          <NoticeBox info>
            {tabs_description[active_tab]}
          </NoticeBox>
        )}
        {settings.map(setting => (
          <SettingField setting={setting} key={setting.type} />
        ))}
      </Window.Content>
    </Window>
  );
};

const SettingField = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  const settingTypes = {
    text: <SettingFieldText {...props} />,
    range: <SettingFieldRange {...props} />,
    choice: <SettingFieldChoice {...props} />,
    hex: <SettingFieldHex {...props} />,
  };

  return (
    <Section>
      <Flex wrap="wrap">
        <Flex.Item basis="30%" grow="2" color="label" pr="1em" bold>
          { setting.name }
        </Flex.Item>
        <Flex.Item basis="50%" shrink grow="2">
          {settingTypes[setting.v_type] || "todo"}
        </Flex.Item>
        {/* button size with icon around 2em, basis here is as min-width to contain them */}
        <Flex.Item basis="6em" grow="1" textAlign="right">
          <Button
            tooltip={"Принять"}
            color="good"
            icon={"check"}
            onClick={() => act("test")}
          />
          <Button
            tooltip={"Отменить"}
            color="bad"
            icon={"times"}
            onClick={() => act("test")}
          />
          <Button
            tooltip={"Сбросить"}
            color="neutral"
            icon={"undo"}
            onClick={() => act("test")}
          />
        </Flex.Item>
        <Flex.Item basis="100%" pt="1em">
          { setting.description } |
          { setting.type } |
          { setting.name } |
          { setting.value } |
          { setting.v_type } |
          { setting.v_variations }
        </Flex.Item>
      </Flex>
    </Section>
  );
};


const SettingFieldRange = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  return (
    <Slider
      value={setting.value}
      minValue={setting.v_variations[0]}
      maxValue={setting.v_variations[1]}
      step={1}
      onChange={(e, value) => act('set_value', { type: setting.type, value: value })}
    />
  );
};

const SettingFieldHex = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  return (
    <>
      <ColorBox
        color={setting.value}
        mr={0.5} 
      />
      <Input fluid
        value={setting.value}
        onInput={(e, value) => act('set_value', { type: setting.type, value: value })}
      />
      <Button
        icon="pencil-alt"
        color="transparent"
        onClick={() => act('modify_color_value', { name: "asd" })} 
      />
    </>
  );
};

const SettingFieldText = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  return (
    <Input fluid
      value={setting.value}
      onInput={(e, value) => act('set_value', { type: setting.type, value: value })}
    />
  );
};

const SettingFieldChoice = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  return (
    <Dropdown fluid
      options={setting.v_variations}
      selected={setting.value}
      onSelected={value => act('set_value', { type: setting.type, value: value })}
    />
  );
};
