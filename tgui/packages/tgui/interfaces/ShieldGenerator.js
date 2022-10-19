/**
 * @file
 * @copyright 2022 Saicchi
 * @author Saicchi (https://github.com/Saicchi)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Flex, Section, Box, Icon, NoticeBox, Tooltip, ProgressBar, Stack, LabeledList } from '../components';
import { Window } from '../layouts';

export const ShieldStatus = (props, context) => {
  const { act, data } = useBackend(context);

  const { active } = data;
  const { anchored, current_charge, power_draw } = props;

  return (
    <Flex direction="column">
      <Flex>
        <Button
          icon="power-off" color={active ? "red" : "green"}
          fontSize={1.25} textAlign="center"
          onClick={() => { act("toggle"); }}>
          {active ? "Deactivate" : "Activate"}
        </Button>
        <Button
          icon="wrench" color={anchored ? "red" : "green"}
          fontSize={1.25} textAlign="center"
          onClick={() => { act("anchor"); }}>
          {anchored ? "Unwrench" : "Wrench"}
        </Button>
        <Flex.Item ml="auto" mt={0.2}>
          <Box color="red" fontSize={1.6}>
            {power_draw}
            <Icon name="bolt" fontSize={1.3} ml={1} mr={1.5} />
          </Box>
        </Flex.Item>
      </Flex>
      <LabeledList.Item label="Cell Power">
        <ProgressBar value={current_charge}
          minValue={0}
          maxValue={100}
          color={current_charge < 35 ? "red" : current_charge < 75 ? "yellow" : "green"} />
      </LabeledList.Item>
    </Flex>
  );
};

export const ShieldRange = (props, context) => {
  const { act } = useBackend(context);

  const { min_range, current_range, max_range } = props;
  const ranges = Array(max_range).fill().map((element, index) => index + 1);

  return (
    <Stack fontSize={1.65}>
      {ranges.map((number) => (
        <Stack.Item nowrap key={number}>
          <Button
            color={current_range === number ? "green" : "blue"}
            disabled={number < min_range}
            onClick={() => { act("range", { range: number }); }}>
            {number}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const ShieldPower = (props, context) => {
  const { act } = useBackend(context);

  const { min_power, current_power, max_power, tooltips } = props;
  const powers = Array(max_power).fill().map((element, index) => index + 1);

  return (
    <Stack fontSize={1.65}>
      {powers.map((number) => (
        <Stack.Item nowrap key={number}>
          <Button
            color={current_power === number ? "green" : "blue"}
            disabled={number < min_power}
            tooltip={number <= tooltips.length ? tooltips[number - 1] : ""}
            tooltipPosition="top"
            onClick={() => { act("power", { power: number }); }}>
            {number}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const ShieldGenerator = (props, context) => {
  const { data } = useBackend(context);

  const { name } = data;
  const { anchored, charge_current, power_draw } = data;
  const { range_min, range_current, range_max } = data;
  const { power_min, power_current, power_max, power_description } = data;

  return (
    <Window
      title={name}
      width={500}
      height={400}>
      <Window.Content>
        <Section title="Status">
          <ShieldStatus
            anchored={anchored}
            current_charge={charge_current}
            power_draw={power_draw} />
        </Section>
        <Section title="Range">
          <ShieldRange
            min_range={range_min}
            current_range={range_current}
            max_range={range_max}
          />
        </Section>
        <Section title="Power">
          <ShieldPower
            min_power={power_min}
            current_power={power_current}
            max_power={power_max}
            tooltips={power_description} />
        </Section>
      </Window.Content>
    </Window>
  );
};
